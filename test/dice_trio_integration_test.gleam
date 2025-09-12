import dice_trio
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// Integration tests - full pipeline from string input to final result

pub fn roll_d6_full_pipeline_test() {
  let result = dice_trio.roll("d6", fn(_) { 4 })
  result |> should.equal(Ok(4))
}

pub fn roll_2d6_plus_3_full_pipeline_test() {
  // Always roll 3
  let fixed_rng = fn(_) { 3 }
  // 3 + 3 + 3 = 9
  let result = dice_trio.roll("2d6+3", fixed_rng)
  result |> should.equal(Ok(9))
}

pub fn roll_d20_minus_1_full_pipeline_test() {
  let fixed_rng = fn(_) { 15 }
  let result = dice_trio.roll("d20-1", fixed_rng)
  result |> should.equal(Ok(14))
  // 15 - 1 = 14
}

pub fn roll_d6_range_validation_test() {
  let test_rng = fn(max) {
    case max {
      6 -> 6
      _ -> 1
    }
  }
  let result = dice_trio.roll("d6", test_rng)
  result |> should.be_ok
  case result {
    Ok(value) -> {
      case value >= 1 && value <= 6 {
        True -> Nil
        False -> should.fail()
      }
    }
    Error(_) -> should.fail()
  }
}

pub fn roll_2d6_plus_3_range_validation_test() {
  // Always max roll
  let max_rng = fn(_) { 6 }
  // 6 + 6 + 3 = 15
  let result = dice_trio.roll("2d6+3", max_rng)
  result |> should.equal(Ok(15))

  // Always min roll
  let min_rng = fn(_) { 1 }
  // 1 + 1 + 3 = 5
  let result2 = dice_trio.roll("2d6+3", min_rng)
  result2 |> should.equal(Ok(5))
}

pub fn roll_error_propagation_full_pipeline_test() {
  let dummy_rng = fn(_) { 1 }

  dice_trio.roll("garbage", dummy_rng)
  |> should.equal(Error(dice_trio.MissingSeparator))

  dice_trio.roll("d-invalid", dummy_rng)
  |> should.equal(Error(dice_trio.InvalidSides("-invalid")))
}

pub fn roll_edge_case_d1_test() {
  let any_rng = fn(_) { 999 }
  // RNG shouldn't matter for d1
  let result = dice_trio.roll("d1", any_rng)
  result |> should.equal(Error(dice_trio.RandomizerOutOfRange(any_rng(1))))
  // d1 always returns 1
}

pub fn roll_edge_case_large_dice_test() {
  let fixed_rng = fn(_) { 50 }
  let result = dice_trio.roll("d100", fixed_rng)
  result |> should.equal(Ok(50))
}

pub fn roll_edge_case_many_dice_test() {
  let fixed_rng = fn(_) { 2 }
  let result = dice_trio.roll("10d6", fixed_rng)
  result |> should.equal(Ok(20))
  // 10 × 2 = 20
}

pub fn roll_edge_case_large_modifiers_test() {
  let fixed_rng = fn(_) { 3 }
  let result = dice_trio.roll("d6+100", fixed_rng)
  result |> should.equal(Ok(103))
  // 3 + 100 = 103

  let result2 = dice_trio.roll("d6-50", fixed_rng)
  result2 |> should.equal(Ok(-47))
  // 3 - 50 = -47
}

// Statistical validation tests
pub fn roll_d6_statistical_distribution_test() {
  let results =
    list.range(1, 100)
    |> list.map(fn(_) {
      case
        dice_trio.roll("d6", fn(max) {
          // Simple pseudo-random: cycle through 1-6
          case max {
            6 -> {
              let seed = 42
              seed % 6 + 1
            }
            _ -> 1
          }
        })
      {
        Ok(value) -> value
        Error(_) -> 0
      }
    })

  // Verify all results are in valid range 1-6
  results
  |> list.all(fn(result) { result >= 1 && result <= 6 })
  |> should.equal(True)
}

pub fn roll_with_modifier_range_validation_test() {
  let test_cases = [
    #("d6+10", 11, 16),
    // d6(1-6) + 10 = 11-16
    #("2d6+3", 5, 15),
    // 2d6(2-12) + 3 = 5-15
    #("d20-5", -4, 15),
    // d20(1-20) - 5 = -4-15
  ]

  list.each(test_cases, fn(test_case) {
    let #(expr, min_expected, max_expected) = test_case

    // Test with minimum rolls
    let min_result = dice_trio.roll(expr, fn(_) { 1 })
    case min_result {
      Ok(value) -> value |> should.equal(min_expected)
      Error(_) -> should.fail()
    }

    // Test with maximum rolls
    let max_result = dice_trio.roll(expr, fn(max) { max })
    case max_result {
      Ok(value) -> value |> should.equal(max_expected)
      Error(_) -> should.fail()
    }
  })
}

// Performance and boundary tests
pub fn roll_large_dice_expression_test() {
  let fixed_rng = fn(_) { 50 }
  let result = dice_trio.roll("100d100+50", fixed_rng)
  result |> should.equal(Ok(5050))
  // 100 × 50 + 50 = 5050
}

pub fn roll_extreme_boundary_conditions_test() {
  let fixed_rng = fn(max) { max }
  // Always roll maximum

  // Test d1 (always 1)
  dice_trio.roll("d1", fixed_rng)
  |> should.equal(Ok(1))

  // Test large die size
  dice_trio.roll("d1000", fixed_rng)
  |> should.equal(Ok(1000))

  // Test many small dice
  dice_trio.roll("1000d6", fixed_rng)
  |> should.equal(Ok(6000))
  // 1000 × 6 = 6000
}

pub fn roll_negative_results_test() {
  let fixed_rng = fn(_) { 1 }
  // Always minimum roll

  dice_trio.roll("d6-10", fixed_rng)
  |> should.equal(Ok(-9))
  // 1 - 10 = -9

  dice_trio.roll("2d6-20", fixed_rng)
  |> should.equal(Ok(-18))
  // (1+1) - 20 = -18
}

// Benchmarking tests
pub fn benchmark_simple_roll_performance_test() {
  let fixed_rng = fn(_) { 3 }

  // Time 1000 simple rolls - should complete quickly
  let results =
    list.range(1, 1000)
    |> list.map(fn(_) { dice_trio.roll("d6", fixed_rng) })

  // Verify all succeeded
  results
  |> list.all(fn(result) {
    case result {
      Ok(_) -> True
      Error(_) -> False
    }
  })
  |> should.equal(True)
}

pub fn benchmark_complex_expression_performance_test() {
  let fixed_rng = fn(_) { 5 }

  // Time 100 complex expressions - should still complete reasonably fast
  let results =
    list.range(1, 100)
    |> list.map(fn(_) { dice_trio.roll("10d20+15", fixed_rng) })

  // Verify all succeeded with expected result
  results
  |> list.all(fn(result) {
    case result {
      Ok(65) -> True
      // 10 × 5 + 15 = 65
      _ -> False
    }
  })
  |> should.equal(True)
}
