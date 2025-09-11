import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type BasicRoll {
  BasicRoll(roll_count: Int, side_count: Int, modifier: Int)
}

pub type DiceError {
  MissingSeparator
  InvalidCount(String)
  InvalidSides(String)
  InvalidModifier(String)
  MalformedInput
}

pub fn parse(input: String) -> Result(BasicRoll, DiceError) {
  let split = string.split(input, "d")
  case split {
    [count, right_of_d] -> {
      use c <- result.try(parse_count(count))
      use snm <- result.try(parse_sides_and_modifier(right_of_d))
      Ok(BasicRoll(c, snm.0, snm.1))
    }
    _ -> Error(MissingSeparator)
  }
}

pub fn parse_count(c: String) -> Result(Int, DiceError) {
  case c == "" {
    True -> Ok(1)
    False -> safe_parse_int(c, InvalidCount)
  }
}

fn safe_parse_int(
  value: String,
  error_fn: fn(String) -> DiceError,
) -> Result(Int, DiceError) {
  int.parse(value) |> result.map_error(fn(_) { error_fn(value) })
}

fn parse_sides_mod_pair(sides: String, modifier: String, negate: Bool, original: String) -> Result(#(Int, Int), DiceError) {
  case sides == "" {
    True -> Error(InvalidSides(original))
    False -> {
      use s <- result.try(safe_parse_int(sides, InvalidSides))
      use m <- result.try(safe_parse_int(modifier, InvalidModifier))
      let final_mod = case negate {
        True -> m * -1
        False -> m
      }
      Ok(#(s, final_mod))
    }
  }
}

pub fn parse_sides_and_modifier(snm: String) -> Result(#(Int, Int), DiceError) {
  case string.contains(snm, "+"), string.contains(snm, "-") {
    True, False -> {
      case string.split(snm, "+") {
        [sides, modifier] -> parse_sides_mod_pair(sides, modifier, False, snm)
        _ -> Error(MalformedInput)
      }
    }
    False, True -> {
      case string.split(snm, "-") {
        [sides, modifier] -> parse_sides_mod_pair(sides, modifier, True, snm)
        _ -> Error(MalformedInput)
      }
    }
    False, False -> {
      use s <- result.try(safe_parse_int(snm, InvalidSides))
      Ok(#(s, 0))
    }
    True, True -> Error(MalformedInput)
  }
}

pub fn roll(
  dice_expression: String,
  rng_fn: fn(Int) -> Int,
) -> Result(Int, DiceError) {
  use roll_result <- result.try(parse(dice_expression))
  list.fold(list.range(1, roll_result.roll_count), 0, fn(acc, _) {
    acc + rng_fn(roll_result.side_count)
  })
  |> Ok
}
