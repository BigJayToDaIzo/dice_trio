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

pub fn roll_edge_case_large_dice_test() {
  dice_trio.roll("d100", fn(_) { 50 }) |> should.equal(Ok(50))
}

// === DetailedRoll Integration Tests ===
pub fn detailed_roll_multiple_dice_statistical_validation_test() {
  let result = dice_trio.detailed_roll("5d6", fn(_) { 3 })
  case result {
    Ok(detailed) -> {
      // Verify array length matches roll_count
      list.length(detailed.individual_rolls) |> should.equal(5)
      // Verify all individual rolls are the expected value
      detailed.individual_rolls |> should.equal([3, 3, 3, 3, 3])
      // Verify total calculation
      detailed.total |> should.equal(15)
    }
    Error(_) -> panic as "Expected successful roll"
  }
}

pub fn detailed_roll_total_calculation_validation_test() {
  let result = dice_trio.detailed_roll("3d6+7", fn(_) { 4 })
  case result {
    Ok(detailed) -> {
      let manual_total =
        list.fold(detailed.individual_rolls, 0, fn(acc, val) { acc + val })
        + detailed.basic_roll.modifier
      detailed.total |> should.equal(manual_total)
      detailed.total |> should.equal(19)
      // (4+4+4) + 7
    }
    Error(_) -> panic as "Expected successful roll"
  }
}

pub fn detailed_roll_negative_total_integration_test() {
  dice_trio.detailed_roll("d6-10", fn(_) { 3 })
  |> should.equal(
    Ok(dice_trio.DetailedRoll(
      dice_trio.BasicRoll(1, 6, -10),
      individual_rolls: [3],
      total: -7,
    )),
  )
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
        // Should never happen
        Error(_) -> 0
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

