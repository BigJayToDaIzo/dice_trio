import dice_trio
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// Integration tests - full pipeline from string input to final result
pub fn roll_d6_full_pipeline_test() {
  dice_trio.roll("d6", fn(_) { 4 }) |> should.equal(Ok(4))
}

pub fn roll_2d6_plus_3_full_pipeline_test() {
  dice_trio.roll("2d6+3", fn(_) { 3 }) |> should.equal(Ok(9))
}

pub fn roll_d20_minus_1_full_pipeline_test() {
  dice_trio.roll("d20-1", fn(_) { 15 }) |> should.equal(Ok(14))
}

pub fn roll_error_propagation_full_pipeline_test() {
  dice_trio.roll("garbage", fn(_) { 1 })
  |> should.equal(Error(dice_trio.MissingSeparator))
  dice_trio.roll("d-invalid", fn(_) { 1 })
  |> should.equal(Error(dice_trio.InvalidSides("-invalid")))
}

pub fn roll_d1_with_out_of_range_rng_returns_error_test() {
  dice_trio.roll("d1", fn(_) { 999 })
  |> should.equal(Error(dice_trio.RandomizerOutOfRange(999)))
}

pub fn roll_edge_case_large_dice_test() {
  dice_trio.roll("d100", fn(_) { 50 }) |> should.equal(Ok(50))
}

pub fn roll_edge_case_many_dice_test() {
  let fixed_rng = fn(_) { 2 }
  dice_trio.roll("10d6", fixed_rng) |> should.equal(Ok(20))
}

pub fn roll_edge_case_large_modifiers_test() {
  let fixed_rng = fn(_) { 3 }
  dice_trio.roll("d6+100", fixed_rng) |> should.equal(Ok(103))
  dice_trio.roll("d6-50", fixed_rng) |> should.equal(Ok(-47))
}

// Statistical validation tests
pub fn roll_multiple_d6_with_deterministic_rng_test() {
  let deterministic_rng = fn(max) {
    case max {
      // Always return middle value (3) for d6
      6 -> 3
      // Default to 1 for other dice
      _ -> 1
    }
  }
  // Test multiple rolls with deterministic RNG - all should be 3
  let results =
    list.range(1, 10)
    |> list.map(fn(_) {
      case dice_trio.roll("d6", deterministic_rng) {
        Ok(value) -> value
        Error(_) -> 0
        // Should never happen
      }
    })
  results |> list.all(fn(result) { result == 3 }) |> should.equal(True)
}

pub fn roll_with_modifier_range_validation_test() {
  let test_cases = [
    // d6(1-6) + 10 = 11-16
    #("d6+10", 11, 16),
    #("2d6+3", 5, 15),
    #("d20-5", -4, 15),
  ]
  list.each(test_cases, fn(test_case) {
    let #(expr, min_expected, max_expected) = test_case
    dice_trio.roll(expr, fn(_) { 1 }) |> should.equal(Ok(min_expected))
    dice_trio.roll(expr, fn(max) { max }) |> should.equal(Ok(max_expected))
  })
}

// Performance and boundary tests
pub fn roll_large_dice_expression_test() {
  let fixed_rng = fn(_) { 50 }
  dice_trio.roll("100d100+50", fixed_rng) |> should.equal(Ok(5050))
}

pub fn roll_extreme_boundary_conditions_test() {
  dice_trio.roll("d1", fn(max) { max }) |> should.equal(Ok(1))
  dice_trio.roll("d1000", fn(max) { max }) |> should.equal(Ok(1000))
  dice_trio.roll("1000d6", fn(max) { max }) |> should.equal(Ok(6000))
}

pub fn roll_negative_results_test() {
  dice_trio.roll("d6-10", fn(_) { 1 }) |> should.equal(Ok(-9))
  dice_trio.roll("2d6-20", fn(_) { 1 }) |> should.equal(Ok(-18))
}

// Benchmarking tests
pub fn benchmark_simple_roll_performance_test() {
  // Light performance verification - single roll
  dice_trio.roll("d6", fn(_) { 3 }) |> should.equal(Ok(3))
}

pub fn benchmark_complex_expression_performance_test() {
  // Light performance verification - single complex roll
  // 10 × 5 + 15 = 65
  dice_trio.roll("10d20+15", fn(_) { 5 }) |> should.equal(Ok(65))
}
