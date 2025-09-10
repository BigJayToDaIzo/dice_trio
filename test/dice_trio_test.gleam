import dice_trio.{BasicRoll, InvalidCount}
import gleeunit

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
  assert actual == Error(Nil)
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
  assert actual == Error(InvalidCount("garbage"))
}
