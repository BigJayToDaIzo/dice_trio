import gleam/int
import gleam/result
import gleam/string

pub type BasicRoll {
  BasicRoll(roll_count: Int, side_count: Int, modifier: Int)
}

pub type DiceError {
  InvalidCount(String)
  InvalidSides(String)
  MalformedInput
}

pub fn parse(input: String) -> Result(BasicRoll, Nil) {
  // break the d here for sides and roll count
  let count_and_sides = string.split(input, "d")

  case count_and_sides {
    ["", sides] -> {
      use sides_parsed <- result.try(int.parse(sides))
      Ok(BasicRoll(1, sides_parsed, 0))
    }
    [count, sides] -> {
      use count_parsed <- result.try(int.parse(count))
      use sides_parsed <- result.try(int.parse(sides))
      Ok(BasicRoll(count_parsed, sides_parsed, 0))
    }
    _ -> Error(Nil)
  }
}
