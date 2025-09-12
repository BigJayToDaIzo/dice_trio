import dice_trio.{BasicRoll}
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn parse_d2_returns_basic_roll_test() {
  dice_trio.parse("d2") 
  |> should.equal(Ok(BasicRoll(roll_count: 1, side_count: 2, modifier: 0)))
}

pub fn parse_invalid_input_returns_error_test() {
  dice_trio.parse("garbage") |> should.equal(Error(dice_trio.MissingSeparator))
}

pub fn parse_2d2_returns_basic_roll_test() {
  dice_trio.parse("2d2") 
  |> should.equal(Ok(BasicRoll(roll_count: 2, side_count: 2, modifier: 0)))
}

pub fn parse_3d6_returns_basic_roll_test() {
  dice_trio.parse("3d6") 
  |> should.equal(Ok(BasicRoll(roll_count: 3, side_count: 6, modifier: 0)))
}

pub fn parse_invalid_count_returns_descriptive_error_test() {
  dice_trio.parse("garbaged6") 
  |> should.equal(Error(dice_trio.InvalidCount("garbage")))
}

pub fn parse_missing_d_returns_missing_separator_test() {
  dice_trio.parse("noseparator") 
  |> should.equal(Error(dice_trio.MissingSeparator))
}

pub fn roll_single_d2_with_fixed_randomness_test() {
  dice_trio.roll("d2", fn(_) { 2 }) |> should.equal(Ok(2))
}

pub fn roll_invalid_input_returns_error_test() {
  dice_trio.roll("garbage", fn(_) { 1 })
  |> should.equal(Error(dice_trio.MissingSeparator))
}

pub fn roll_invalid_sides_returns_error_test() {
  dice_trio.roll("d-garbage", fn(_) { 1 })
  |> should.equal(Error(dice_trio.InvalidSides("-garbage")))
}

pub fn roll_multiple_dice_with_fixed_randomness_test() {
  dice_trio.roll("2d6", fn(_) { 3 }) |> should.equal(Ok(6))
}

pub fn parse_d6_plus_2_returns_basic_roll_with_modifier_test() {
  dice_trio.parse("d6+2") 
  |> should.equal(Ok(BasicRoll(roll_count: 1, side_count: 6, modifier: 2)))
}

pub fn parse_valid_dice_count_succeeds_test() {
  dice_trio.parse_count("2") |> should.equal(Ok(2))
}

pub fn parse_invalid_dice_count_returns_error_test() {
  dice_trio.parse_count("abc") |> should.equal(Error(dice_trio.InvalidCount("abc")))
}

pub fn parse_sides_and_modifier_no_modifier_test() {
  dice_trio.parse_sides_and_modifier("6") |> should.equal(Ok(#(6, 0)))
}

pub fn parse_sides_and_modifier_with_positive_test() {
  dice_trio.parse_sides_and_modifier("6+2") |> should.equal(Ok(#(6, 2)))
}

pub fn parse_sides_and_modifier_with_negative_test() {
  dice_trio.parse_sides_and_modifier("6-1") |> should.equal(Ok(#(6, -1)))
}

pub fn parse_malformed_modifier_syntax_returns_error_test() {
  dice_trio.parse_sides_and_modifier("6+-1") |> should.equal(Error(dice_trio.MalformedInput))
}

// Edge case tests - input validation
pub fn parse_empty_string_test() {
  dice_trio.parse("") |> should.equal(Error(dice_trio.MissingSeparator))
}

pub fn parse_whitespace_only_test() {
  dice_trio.parse("   ") |> should.equal(Error(dice_trio.MissingSeparator))
}

pub fn parse_whitespace_around_d6_test() {
  dice_trio.parse(" d6 ")
  |> should.equal(Ok(BasicRoll(roll_count: 1, side_count: 6, modifier: 0)))
}

pub fn parse_zero_dice_count_test() {
  dice_trio.parse("0d6") |> should.equal(Error(dice_trio.InvalidCount("0")))
}

pub fn parse_zero_sides_test() {
  dice_trio.parse("1d0")
  |> should.equal(
    Ok(dice_trio.BasicRoll(roll_count: 1, side_count: 0, modifier: 0)),
  )
}

pub fn parse_negative_dice_count_test() {
  dice_trio.parse("-1d6") |> should.equal(Error(dice_trio.InvalidCount("-1")))
}

pub fn parse_negative_sides_test() {
  dice_trio.parse("1d-6") |> should.equal(Error(dice_trio.InvalidSides("-6")))
}

pub fn parse_malformed_modifier_no_number_positive_test() {
  dice_trio.parse("d6+") |> should.equal(Error(dice_trio.InvalidModifier("")))
}

pub fn parse_malformed_modifier_no_number_negative_test() {
  dice_trio.parse("d6-") |> should.equal(Error(dice_trio.InvalidModifier("")))
}

pub fn parse_malformed_modifier_double_plus_test() {
  dice_trio.parse("d6++1") |> should.equal(Error(dice_trio.MalformedInput))
}

pub fn parse_malformed_modifier_double_minus_test() {
  dice_trio.parse("d6--1") |> should.equal(Error(dice_trio.MalformedInput))
}

pub fn parse_very_large_numbers_test() {
  dice_trio.parse("999d999+999") 
  |> should.equal(Ok(dice_trio.BasicRoll(roll_count: 999, side_count: 999, modifier: 999)))
}
