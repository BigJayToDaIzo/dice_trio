import dice_trio
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// End-to-end tests with real randomness - testing actual RNG integration
// Deterministic RNG that returns predictable values for testing
fn deterministic_rng(value: Int) -> fn(Int) -> Int {
  fn(_max) { value }
}

pub fn roll_with_deterministic_rng_produces_valid_results_test() {
  dice_trio.roll("d6", deterministic_rng(4)) |> should.equal(Ok(4))
  // Range validation covered by integration tests
}

pub fn roll_complex_expression_with_deterministic_rng_test() {
  dice_trio.roll("2d6+3", deterministic_rng(5)) |> should.equal(Ok(13))
}

pub fn roll_negative_modifier_with_deterministic_rng_test() {
  dice_trio.roll("d6-3", deterministic_rng(2)) |> should.equal(Ok(-1))
}

pub fn roll_guaranteed_negative_results_test() {
  dice_trio.roll("d6-10", deterministic_rng(3)) |> should.equal(Ok(-7))
  let result = dice_trio.roll("d6-10", deterministic_rng(3))
  case result {
    Ok(value) -> { value < 0 } |> should.equal(True)
    Error(_) -> should.fail()
  }
}

pub fn roll_large_dice_with_deterministic_rng_performance_test() {
  dice_trio.roll("10d20+5", deterministic_rng(12)) |> should.equal(Ok(125))
}

pub fn rng_contract_violation_detection_test() {
  let bad_rng = fn(_) { 0 }
  dice_trio.roll("d6", bad_rng)
  |> should.equal(Error(dice_trio.RandomizerOutOfRange(0)))
  let high_rng = fn(_) { 10 }
  dice_trio.roll("d6", high_rng)
  |> should.equal(Error(dice_trio.RandomizerOutOfRange(10)))
}
