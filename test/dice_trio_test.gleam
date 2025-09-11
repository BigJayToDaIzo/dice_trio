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

pub fn roll_multiple_dice_with_fixed_randomness_test() {
  let fixed_rng = fn(_max) { 3 }

  dice_trio.roll("2d6", fixed_rng)
  |> should.equal(Ok(6))
}

pub fn parse_d6_plus_2_returns_basic_roll_with_modifier_test() {
  let input = "d6+2"
  let expected = Ok(BasicRoll(roll_count: 1, side_count: 6, modifier: 2))
  let actual = dice_trio.parse(input)
  assert actual == expected
}

pub fn parse_count_happy_path_test() {
  let input = "2"
  let expected = Ok(2)
  let actual = dice_trio.parse_count(input)
  assert actual == expected
}

pub fn parse_count_sad_path_test() {
  let input = "abc"
  let expected = Error(dice_trio.InvalidCount("abc"))
  let actual = dice_trio.parse_count(input)
  assert actual == expected
}

pub fn parse_sides_and_modifier_no_modifier_test() {
  let input = "6"
  let expected = Ok(#(6, 0))
  let actual = dice_trio.parse_sides_and_modifier(input)
  assert actual == expected
}

pub fn parse_sides_and_modifier_with_positive_test() {
  let input = "6+2"
  let expected = Ok(#(6, 2))
  let actual = dice_trio.parse_sides_and_modifier(input)
  assert actual == expected
}

pub fn parse_sides_and_modifier_with_negative_test() {
  let input = "6-1"
  let expected = Ok(#(6, -1))
  let actual = dice_trio.parse_sides_and_modifier(input)
  assert actual == expected
}

pub fn parse_sides_and_modifier_sad_path_test() {
  let input = "6+-1"
  let expected = Error(dice_trio.MalformedInput)
  let actual = dice_trio.parse_sides_and_modifier(input)
  assert actual == expected
}

// Edge case tests - input validation

pub fn parse_empty_string_test() {
  let input = ""
  let actual = dice_trio.parse(input)
  assert actual == Error(dice_trio.MissingSeparator)
}

pub fn parse_whitespace_only_test() {
  let input = "   "
  let actual = dice_trio.parse(input)
  assert actual == Error(dice_trio.MissingSeparator)
}

pub fn parse_zero_dice_count_test() {
  let input = "0d6"
  let actual = dice_trio.parse(input)
  assert actual == Error(dice_trio.InvalidCount("0"))
}

pub fn parse_zero_sides_test() {
  let input = "1d0"
  let actual = dice_trio.parse(input)
  assert actual
    == Ok(dice_trio.BasicRoll(roll_count: 1, side_count: 0, modifier: 0))
}

pub fn parse_negative_dice_count_test() {
  let input = "-1d6"
  let actual = dice_trio.parse(input)
  assert actual == Error(dice_trio.InvalidCount("-1"))
}

pub fn parse_negative_sides_test() {
  let input = "1d-6"
  let actual = dice_trio.parse(input)
  assert actual == Error(dice_trio.InvalidSides("-6"))
}

pub fn parse_malformed_modifier_no_number_positive_test() {
  let input = "d6+"
  let actual = dice_trio.parse(input)
  assert actual == Error(dice_trio.InvalidModifier(""))
}

pub fn parse_malformed_modifier_no_number_negative_test() {
  let input = "d6-"
  let actual = dice_trio.parse(input)
  assert actual == Error(dice_trio.InvalidModifier(""))
}

pub fn parse_malformed_modifier_double_plus_test() {
  let input = "d6++1"
  let actual = dice_trio.parse(input)
  assert actual == Error(dice_trio.MalformedInput)
}

pub fn parse_malformed_modifier_double_minus_test() {
  let input = "d6--1"
  let actual = dice_trio.parse(input)
  assert actual == Error(dice_trio.MalformedInput)
}

pub fn parse_very_large_numbers_test() {
  let input = "999d999+999"
  let expected =
    Ok(dice_trio.BasicRoll(roll_count: 999, side_count: 999, modifier: 999))
  let actual = dice_trio.parse(input)
  assert actual == expected
}
