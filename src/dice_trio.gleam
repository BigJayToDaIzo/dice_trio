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
  MalformedInput
}

pub fn parse(input: String) -> Result(BasicRoll, DiceError) {
  let modifier = contains_plus_or_minus(input)

  let count_and_sides = string.split(modifier.1, "d")

  case count_and_sides {
    ["", sides] -> {
      use sides_parsed <- result.try(
        int.parse(sides) |> result.map_error(fn(_) { InvalidSides(sides) }),
      )
      Ok(BasicRoll(1, sides_parsed, modifier.0))
    }
    [count, sides] -> {
      use count_parsed <- result.try(
        int.parse(count) |> result.map_error(fn(_) { InvalidCount(count) }),
      )
      use sides_parsed <- result.try(
        int.parse(sides) |> result.map_error(fn(_) { InvalidSides(sides) }),
      )
      Ok(BasicRoll(count_parsed, sides_parsed, 0))
    }
    _ -> {
      // Check if input contains 'd' separator
      case string.contains(input, "d") {
        False -> Error(MissingSeparator)
        True -> Error(MalformedInput)
      }
    }
  }
}

pub fn contains_plus_or_minus(input: String) -> #(Int, String) {
  case string.contains(input, "+") {
    True -> {
      string.split(input, "+")
      |> fn(list) {
        case list {
          [unmodified, modifier] -> {
            let assert Ok(mod) = int.parse(modifier)
            #(mod, unmodified)
          }
          [unmodified] -> #(0, unmodified)
          _ -> #(0, "")
        }
      }
    }
    False -> #(0, input)
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
  |> fn(sum) { Ok(sum) }
}
