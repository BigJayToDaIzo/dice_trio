import dice_trio
import gleam/list
import gleeunit
import gleeunit/should
import prng/random

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

// === Real-World RNG Contract Validation Tests ===
// These tests use the `prng` library (https://hex.pm/packages/prng) by Gleam core team member Jak (Giacomo Cavalieri)
// as a reference implementation showing how to integrate high-quality RNG with dice_trio.
// Game developers can use this as a template for validating their own RNG functions.
pub fn real_rng_d6_contract_validation_test() {
  let rng_fn = fn(max: Int) {
    let dice_roll = random.int(1, max)
    random.random_sample(dice_roll)
  }
  list.range(1, 100)
  |> list.all(fn(_) {
    case dice_trio.roll("d6", rng_fn) {
      // Run 100 d6 rolls and validate ALL are in range 1-6
      Ok(result) -> result >= 1 && result <= 6
      Error(_) -> False
    }
  })
  |> should.be_true()
}

pub fn real_rng_d20_contract_validation_test() {
  let rng_fn = fn(max: Int) {
    let dice_roll = random.int(1, max)
    random.random_sample(dice_roll)
  }
  list.range(1, 500)
  |> list.all(fn(_) {
    case dice_trio.roll("d20", rng_fn) {
      // Run 500 d20 rolls and validate ALL are in range 1-20
      Ok(result) -> result >= 1 && result <= 20
      Error(_) -> False
    }
  })
  |> should.be_true()
}

pub fn real_rng_complex_expression_contract_validation_test() {
  let rng_fn = fn(max: Int) {
    let dice_roll = random.int(1, max)
    random.random_sample(dice_roll)
  }
  list.range(1, 100)
  |> list.all(fn(_) {
    case dice_trio.roll("2d6+3", rng_fn) {
      // Test "2d6+3" - should be in range 5-15 (2+3 to 12+3)
      Ok(result) -> result >= 5 && result <= 15
      Error(_) -> False
    }
  })
  |> should.be_true()
}

pub fn real_rng_detailed_roll_contract_validation_test() {
  let rng_fn = fn(max: Int) {
    let dice_roll = random.int(1, max)
    random.random_sample(dice_roll)
  }
  list.range(1, 50)
  |> list.all(fn(_) {
    case dice_trio.detailed_roll("3d8", rng_fn) {
      Ok(detailed) -> {
        // All individual rolls should be 1-8
        detailed.individual_rolls
        |> list.all(fn(roll) { roll >= 1 && roll <= 8 })
      }
      Error(_) -> False
    }
  })
  |> should.be_true()
}

pub fn real_rng_extreme_negative_modifier_contract_validation_test() {
  let rng_fn = fn(max: Int) {
    let dice_roll = random.int(1, max)
    random.random_sample(dice_roll)
  }
  // Test "d6-10" - even max roll (6) gives -4, min roll (1) gives -9
  list.range(1, 200)
  |> list.all(fn(_) {
    case dice_trio.roll("d6-10", rng_fn) {
      // Should be in range -9 to -4
      Ok(result) -> result >= -9 && result <= -4
      Error(_) -> False
    }
  })
  |> should.be_true()
}
