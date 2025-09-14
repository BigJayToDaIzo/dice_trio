import dice_trio
import gleam/list
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

// === DetailedRoll E2E Tests ===
// Note: These tests cover some scenarios identically to integration tests for comprehensive validation
pub fn detailed_roll_large_dice_performance_e2e_test() {
  dice_trio.detailed_roll("100d6+25", deterministic_rng(3))
  |> should.equal(
    Ok(dice_trio.DetailedRoll(
      dice_trio.BasicRoll(100, 6, 25),
      individual_rolls: list.repeat(3, 100),
      total: 325,
    )),
  )
}

pub fn detailed_roll_damage_calculation_scenario_test() {
  // Simulates "fireball does 8d6 fire damage"
  let result = dice_trio.detailed_roll("8d6", deterministic_rng(4))
  case result {
    Ok(detailed) -> {
      list.length(detailed.individual_rolls) |> should.equal(8)
      detailed.total |> should.equal(32)
      detailed.individual_rolls
      |> list.all(fn(roll) { roll == 4 })
      |> should.be_true()
    }
    Error(_) -> panic as "Expected successful damage roll"
  }
}

pub fn detailed_roll_character_stats_scenario_test() {
  // Very similar to prior test, but
  // simulates "roll 4d6, drop lowest" preparation
  let result = dice_trio.detailed_roll("4d6", deterministic_rng(5))
  case result {
    Ok(detailed) -> {
      list.length(detailed.individual_rolls) |> should.equal(4)
      detailed.total |> should.equal(20)
      // Game logic would drop lowest from detailed.individual_rolls
    }
    Error(_) -> panic as "Expected successful stat roll"
  }
}

pub fn detailed_roll_extreme_load_e2e_test() {
  dice_trio.detailed_roll("1000d6", deterministic_rng(1))
  |> should.be_ok()
  // Just verify it doesn't crash with extreme loads
}
