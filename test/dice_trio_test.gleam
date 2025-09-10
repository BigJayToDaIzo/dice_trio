import dice_trio.{BasicRoll}
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn parse_d2_returns_basic_roll_test() {
  let input = "d2"
  let expected = Ok(BasicRoll(roll_count: 1, side_count: 2, modifier: 0))
  let actual = dice_trio.parse(input)
  assert actual == expected
}

pub fn parse_invalid_input_returns_error_test() {
  let input = "garbage"
  let actual = dice_trio.parse(input)
  assert actual == Error(dice_trio.MissingSeparator)
}

pub fn parse_2d2_returns_basic_roll_test() {
  let input = "2d2"
  let expected = Ok(BasicRoll(roll_count: 2, side_count: 2, modifier: 0))
  let actual = dice_trio.parse(input)
  assert actual == expected
}

pub fn parse_3d6_returns_basic_roll_test() {
  let input = "3d6"
  let expected = Ok(BasicRoll(roll_count: 3, side_count: 6, modifier: 0))
  let actual = dice_trio.parse(input)
  assert actual == expected
}

pub fn parse_invalid_count_returns_descriptive_error_test() {
  let input = "garbaged6"
  let actual = dice_trio.parse(input)
  assert actual == Error(dice_trio.InvalidCount("garbage"))
}

pub fn parse_missing_d_returns_missing_separator_test() {
  let input = "noseparator"
  let actual = dice_trio.parse(input)
  assert actual == Error(dice_trio.MissingSeparator)
}

pub fn roll_single_d2_with_fixed_randomness_test() {
  let fixed_rng = fn(_max) { 2 }
  
  dice_trio.roll("d2", fixed_rng)
  |> should.equal(Ok(2))
}

pub fn roll_invalid_input_returns_error_test() {
  let dummy_rng = fn(_max) { 1 }
  
  dice_trio.roll("garbage", dummy_rng)
  |> should.equal(Error(dice_trio.MissingSeparator))
}

pub fn roll_invalid_sides_returns_error_test() {
  let dummy_rng = fn(_max) { 1 }
  
  dice_trio.roll("d-garbage", dummy_rng)
  |> should.equal(Error(dice_trio.InvalidSides("-garbage")))
}
