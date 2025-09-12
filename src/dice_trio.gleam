//// A minimal, bulletproof dice rolling library following the Unix philosophy.
////
//// `dice_trio` does one thing exceptionally well: parse and roll standard dice expressions.
//// It provides a simple, reliable foundation for building game systems.
////
//// ## Quick Start
////
//// ```gleam
//// import dice_trio
////
//// // Your RNG function (1-to-max inclusive)
//// let rng = fn(max) { your_random_implementation(max) }
////
//// // Roll some dice
//// dice_trio.roll("d6", rng)        // Ok(4)
//// dice_trio.roll("2d6+3", rng)     // Ok(11)
//// dice_trio.roll("d20-1", rng)     // Ok(18)
//// ```
////
//// ## Supported Notation
////
//// - `"d6"` - Single six-sided die
//// - `"2d6"` - Two six-sided dice
//// - `"d6+2"` - Six-sided die plus 2
//// - `"d20-1"` - Twenty-sided die minus 1
//// - `"3d6+5"` - Three dice with modifier
////
//// ## Design Philosophy
////
//// - **Unix Philosophy**: Do one thing exceptionally well
//// - **Maximum Approachability**: Game systems should be simple to build
//// - **RNG Injection**: Bring your own randomness for testing/determinism
//// - **Comprehensive Validation**: Clear errors for invalid input
//// - **Performance Tested**: Handles extreme loads (1000d6, 100d100+50)

import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

/// Represents a parsed dice expression with count, sides, and modifier.
///
/// ## Examples
///
/// ```gleam
/// BasicRoll(roll_count: 2, side_count: 6, modifier: 3)  // 2d6+3
/// BasicRoll(roll_count: 1, side_count: 20, modifier: -1) // d20-1
/// ```
pub type BasicRoll {
  BasicRoll(roll_count: Int, side_count: Int, modifier: Int)
}

/// All possible errors that can occur when parsing or rolling dice expressions.
pub type DiceError {
  /// No "d" separator found in input (e.g., "garbage")
  MissingSeparator
  /// Invalid dice count provided (e.g., "abc" in "abcd6" or negative counts)
  InvalidCount(String)
  /// Invalid die sides provided (e.g., "-6" in "d-6")
  InvalidSides(String)
  /// Invalid modifier provided (e.g., empty string in "d6+")
  InvalidModifier(String)
  /// Malformed input that doesn't follow expected patterns
  MalformedInput
  /// RNG function returned value outside expected 1-to-max range
  RandomizerOutOfRange(Int)
}

/// Parses a dice expression string into structured components.
///
/// Supports standard dice notation: `XdY+Z` where:
/// - X is dice count (optional, defaults to 1)
/// - Y is die sides (required)
/// - Z is modifier (optional, defaults to 0)
///
/// ## Examples
///
/// ```gleam
/// parse("d6")
/// // Ok(BasicRoll(roll_count: 1, side_count: 6, modifier: 0))
///
/// parse("2d6+3")
/// // Ok(BasicRoll(roll_count: 2, side_count: 6, modifier: 3))
///
/// parse("d20-1")
/// // Ok(BasicRoll(roll_count: 1, side_count: 20, modifier: -1))
///
/// parse("invalid")
/// // Error(MissingSeparator)
/// ```
pub fn parse(input: String) -> Result(BasicRoll, DiceError) {
  case string.trim(input) |> string.split_once("d") {
    Ok(#(count, right_of_d)) -> {
      use c <- result.try(parse_count(count))
      use snm <- result.try(parse_sides_and_modifier(right_of_d))
      Ok(BasicRoll(c, snm.0, snm.1))
    }
    Error(Nil) -> Error(MissingSeparator)
  }
}

/// Parses the dice count portion of a dice expression.
///
/// Empty strings default to 1 (for expressions like "d6").
/// Validates that counts are positive integers.
///
/// ## Examples
///
/// ```gleam
/// parse_count("")    // Ok(1)   - defaults to 1
/// parse_count("2")   // Ok(2)   - explicit count
/// parse_count("0")   // Error(InvalidCount("0"))
/// parse_count("-1")  // Error(InvalidCount("-1"))
/// ```
pub fn parse_count(c: String) -> Result(Int, DiceError) {
  case c == "" {
    True -> Ok(1)
    False -> {
      use parsed_count <- result.try(safe_parse_int(c, InvalidCount))
      case parsed_count < 1 {
        True -> Error(InvalidCount(c))
        False -> Ok(parsed_count)
      }
    }
  }
}

fn safe_parse_int(
  value: String,
  error_fn: fn(String) -> DiceError,
) -> Result(Int, DiceError) {
  int.parse(value) |> result.map_error(fn(_) { error_fn(value) })
}

fn parse_sides_mod_pair(
  sides: String,
  modifier: String,
  negate: Bool,
  original: String,
) -> Result(#(Int, Int), DiceError) {
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

/// Parses the sides and modifier portion of a dice expression.
///
/// Handles the part after "d" in expressions like "6+3", "20-1", or just "6".
/// Returns a tuple of (sides, modifier).
///
/// ## Examples
///
/// ```gleam
/// parse_sides_and_modifier("6")     // Ok(#(6, 0))   - no modifier
/// parse_sides_and_modifier("6+3")   // Ok(#(6, 3))   - positive modifier
/// parse_sides_and_modifier("20-1")  // Ok(#(20, -1)) - negative modifier
/// parse_sides_and_modifier("6++1")  // Error(MalformedInput)
/// ```
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

/// Parses and rolls a dice expression, returning the total result.
///
/// This is the main function for dice rolling. It parses the expression and
/// then uses your provided RNG function to generate random numbers for each die.
///
/// ## Parameters
///
/// - `dice_expression`: Standard dice notation string (`"d6"`, `"2d6+3"`, etc.)
/// - `rng_fn`: Function that takes a max value and returns a random 1-to-max number
///
/// ## RNG Function Contract
///
/// Your RNG function must:
/// - Take an `Int` parameter (the die size)
/// - Return a value between 1 and that parameter (inclusive)
/// - For a d6, return 1, 2, 3, 4, 5, or 6
///
/// ## Examples
///
/// ```gleam
/// // Simple roll with fixed RNG for testing
/// let test_rng = fn(_) { 3 }
/// roll("d6", test_rng)        // Ok(3)
/// roll("2d6+5", test_rng)     // Ok(11)  // 3 + 3 + 5
///
/// // Error handling
/// roll("invalid", test_rng)   // Error(MissingSeparator)
/// roll("0d6", test_rng)       // Error(InvalidCount("0"))
/// ```
pub fn roll(
  dice_expression: String,
  rng_fn: fn(Int) -> Int,
) -> Result(Int, DiceError) {
  use roll_result <- result.try(parse(dice_expression))
  use <- bool.guard(
    rng_fn(roll_result.side_count) < 1
      || rng_fn(roll_result.side_count) > roll_result.side_count,
    Error(RandomizerOutOfRange(rng_fn(roll_result.side_count))),
  )
  list.fold(list.range(1, roll_result.roll_count), 0, fn(acc, _) {
    acc + rng_fn(roll_result.side_count)
  })
  |> fn(pre_mod) { Ok(pre_mod + roll_result.modifier) }
}
