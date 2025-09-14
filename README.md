# dice_trio

> The Unix philosophy applied to dice rolling: do one thing exceptionally well.

[![Package Version](https://img.shields.io/hexpm/v/dice_trio)](https://hex.pm/packages/dice_trio)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/dice_trio/)

A minimal, bulletproof dice rolling library for Gleam that focuses on standard dice notation with maximum API approachability.

## Philosophy

`dice_trio` embodies the Unix philosophy - it does **one thing** (parse and roll standard dice expressions) and does it **exceptionally well**. No exotic mechanics, no complex features, just rock-solid dice math that game developers can depend on.

## Features

- ✅ **Standard Dice Notation**: `d6`, `2d6+3`, `d20-1`
- ✅ **Bulletproof Parsing**: Comprehensive input validation with clear error messages
- ✅ **Performance Tested**: Handles extreme loads (`1000d6`, `100d100+50`)
- ✅ **Statistically Validated**: 39 comprehensive tests ensure correctness
- ✅ **Zero Dependencies**: Pure Gleam with only stdlib
- ✅ **RNG Injectable**: Bring your own randomness function for testing/determinism

## Installation

```sh
gleam add dice_trio
```

## Usage

### Basic Rolling

```gleam
import dice_trio

// Simple dice roll with your RNG function
let rng = fn(max) { // your random 1-to-max implementation }

dice_trio.roll("d6", rng)        // Ok(4)
dice_trio.roll("2d6+3", rng)     // Ok(11)
dice_trio.roll("d20-1", rng)     // Ok(14)

// Detailed rolling with individual die results
dice_trio.detailed_roll("2d6+3", rng)
// Ok(DetailedRoll(
//   basic_roll: BasicRoll(2, 6, 3),
//   individual_rolls: [4, 5],
//   total: 12
// ))
```

### Recommended RNG Library

For production use, we recommend the [`prng`](https://hex.pm/packages/prng) library by Gleam core team member Jak ([Giacomo Cavalieri](https://github.com/giacomocavalieri)). It's extensively tested in our E2E test suite and provides excellent performance with cross-platform compatibility:

```sh
gleam add prng
```

```gleam
import dice_trio
import prng/random

pub fn game_roll() {
  let rng_fn = fn(max: Int) {
    let generator = random.int(1, max)
    random.random_sample(generator)
  }

  dice_trio.roll("3d6+2", rng_fn)  // Ok(14)
}
```

### Parsing Only

```gleam
import dice_trio

// Parse dice expression into structured data
dice_trio.parse("2d6+3")
// Ok(BasicRoll(roll_count: 2, side_count: 6, modifier: 3))

dice_trio.parse("invalid")
// Error(MissingSeparator)
```

### Error Handling

```gleam
import dice_trio

dice_trio.roll("garbage", rng)
// Error(MissingSeparator)

dice_trio.roll("0d6", rng)  
// Error(InvalidCount("0"))

dice_trio.roll("d-5", rng)
// Error(InvalidSides("-5"))
```

## API Reference

### Types

```gleam
pub type BasicRoll {
  BasicRoll(roll_count: Int, side_count: Int, modifier: Int)
}

pub type DetailedRoll {
  DetailedRoll(basic_roll: BasicRoll, individual_rolls: List(Int), total: Int)
}

pub type DiceError {
  MissingSeparator
  InvalidCount(String)
  InvalidSides(String)
  InvalidModifier(String)
  MalformedInput
}
```

### Functions

#### `roll(dice_expression: String, rng_fn: fn(Int) -> Int) -> Result(Int, DiceError)`

Parses and rolls a dice expression, returning the total result.

- **`dice_expression`**: Standard dice notation (`"d6"`, `"2d6+3"`, `"d20-1"`)
- **`rng_fn`**: Function that takes max value and returns 1-to-max random number
- **Returns**: `Ok(total)` or detailed error

#### `parse(input: String) -> Result(BasicRoll, DiceError)`

Parses dice expression into structured data without rolling.

- **`input`**: Dice expression string
- **Returns**: Parsed dice components or validation error

#### `detailed_roll(dice_expression: String, rng_fn: fn(Int) -> Int) -> Result(DetailedRoll, DiceError)`

Parses and rolls a dice expression, returning detailed results with individual die values.

- **`dice_expression`**: Standard dice notation (`"d6"`, `"2d6+3"`, `"d20-1"`)
- **`rng_fn`**: Function that takes max value and returns 1-to-max random number
- **Returns**: `Ok(DetailedRoll)` with individual dice results or detailed error

## Supported Notation

| Expression | Description | Example Result |
|------------|-------------|----------------|
| `"d6"` | Single six-sided die | `Ok(4)` |
| `"2d6"` | Two six-sided dice | `Ok(9)` |
| `"d6+2"` | Six-sided die plus 2 | `Ok(6)` |
| `"d20-1"` | Twenty-sided die minus 1 | `Ok(18)` |
| `"3d6+5"` | Three dice plus modifier | `Ok(14)` |

## Input Validation

`dice_trio` validates all input and provides clear error messages:

- **Negative dice counts**: `"-1d6"` → `Error(InvalidCount("-1"))`
- **Zero dice**: `"0d6"` → `Error(InvalidCount("0"))`
- **Invalid sides**: `"d-6"` → `Error(InvalidSides("-6"))`
- **Malformed modifiers**: `"d6+"` → `Error(InvalidModifier(""))`
- **Missing separator**: `"garbage"` → `Error(MissingSeparator)`

## Performance

Validated under extreme conditions:
- ✅ 1000 simple rolls (`"d6"`) - instant
- ✅ 100 complex expressions (`"10d20+15"`) - smooth  
- ✅ Extreme loads (`"1000d6"`, `"100d100+50"`) - no issues

## Testing

`dice_trio` has **60 comprehensive tests**:
- **34 unit tests**: Parsing, validation, edge cases, detailed roll functionality
- **12 integration tests**: Cross-component validation, performance, statistical verification
- **14 end-to-end tests**: Real-world scenarios, RNG contract validation with 1,050+ validation rolls

```sh
gleam test  # All tests should pass
```

## Design Principles

### Unix Philosophy
Do one thing exceptionally well. `dice_trio` handles standard dice notation and nothing else.

### Maximum API Approachability  
Game system modules should be simple to write:
```gleam
pub fn attack_roll(modifier: Int) {
  dice_trio.roll("1d20+" <> int.to_string(modifier))
  |> handle_game_logic
}
```

### RNG Injection Pattern
Bring your own randomness for testing, determinism, or custom distributions:
```gleam
import prng/random

// Testing with fixed results
let test_rng = fn(_) { 3 }
dice_trio.roll("2d6", test_rng)  // Always returns Ok(6)

// Production with real randomness using prng
let prng_rng = fn(max: Int) {
  let generator = random.int(1, max)
  random.random_sample(generator)
}
dice_trio.roll("2d6", prng_rng)  // Real randomness
```

## Ecosystem Vision

`dice_trio` is designed as the foundation for a modular ecosystem:

- **`dice_trio_detailed`** - Rich roll breakdowns and dice arrays
- **`dice_trio_stats`** - Statistical analysis and probabilities  
- **`dice_trio_dnd`** - AD&D mechanics (advantage, crits, etc.)
- **`dice_trio_cli`** - Pretty terminal output and formatting

Each extension builds on the bulletproof core while maintaining focused responsibilities.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests (39 comprehensive tests)
gleam check # Type checking
gleam format # Code formatting
```

## Contributing

This library follows strict TDD and focuses on reliability over features. Before adding functionality:

1. Ensure it aligns with standard dice notation
2. Add comprehensive tests (both unit and integration)  
3. Maintain zero external dependencies
4. Preserve the simple, approachable API

---

**dice_trio**: The reliable foundation for dice-based game systems. 🎲

Further documentation can be found at <https://hexdocs.pm/dice_trio>.
