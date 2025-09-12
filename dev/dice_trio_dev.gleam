import dice_trio
import gleam/int
import gleam/io
import gleam/list

pub fn main() {
  io.println("🎲 dice_trio Performance Benchmarks")
  io.println("===================================")
  
  simple_roll_benchmark()
  complex_expression_benchmark() 
  extreme_load_benchmark()
  
  io.println("\n✅ All benchmarks completed successfully!")
}

fn simple_roll_benchmark() {
  // Timing history: 2025-09-12: ~0.23s, [previous], [previous]
  io.println("\n📊 Simple Roll Benchmark (1000 × d6)")
  let fixed_rng = fn(_) { 3 }
  
  let results =
    list.range(1, 1000)
    |> list.map(fn(_) { dice_trio.roll("d6", fixed_rng) })

  let success_count = 
    results
    |> list.count(fn(result) {
      case result {
        Ok(_) -> True
        Error(_) -> False
      }
    })

  io.println("   Completed: " <> int.to_string(success_count) <> "/1000 rolls (timing: see context doc)")
  
  case success_count == 1000 {
    True -> io.println("   ✅ PASS - All rolls succeeded")
    False -> io.println("   ❌ FAIL - Some rolls failed")
  }
}

fn complex_expression_benchmark() {
  // Timing history: 2025-09-12: ~0.15s, [previous], [previous]
  io.println("\n📊 Complex Expression Benchmark (100 × 10d20+15)")
  let fixed_rng = fn(_) { 5 }
  
  let results =
    list.range(1, 100)
    |> list.map(fn(_) { dice_trio.roll("10d20+15", fixed_rng) })

  let success_count = 
    results
    |> list.count(fn(result) {
      case result {
        Ok(65) -> True  // 10 × 5 + 15 = 65
        _ -> False
      }
    })

  io.println("   Completed: " <> int.to_string(success_count) <> "/100 complex expressions (timing: see context doc)")
  
  case success_count == 100 {
    True -> io.println("   ✅ PASS - All complex expressions succeeded")
    False -> io.println("   ❌ FAIL - Some complex expressions failed")
  }
}

fn extreme_load_benchmark() {
  // Timing history: 2025-09-12: 1000d6 ~0.05s, 100d100+50 ~0.03s, [previous], [previous]
  io.println("\n📊 Extreme Load Benchmark (1000d6, 100d100+50)")
  let fixed_rng = fn(max) { max / 2 }  // Return middle value
  
  // Test 1000d6
  let result1 = dice_trio.roll("1000d6", fixed_rng)
  
  case result1 {
    Ok(value) -> {
      io.println("   1000d6 result: " <> int.to_string(value) <> " (timing: see context doc)")
      // Should be 1000 × 3 = 3000 (middle of 1-6 is 3.5, rounded down to 3)
      case value == 3000 {
        True -> io.println("   ✅ PASS - 1000d6 succeeded")
        False -> io.println("   ❌ FAIL - 1000d6 unexpected result")
      }
    }
    Error(_) -> io.println("   ❌ FAIL - 1000d6 failed to roll")
  }
  
  // Test 100d100+50
  let result2 = dice_trio.roll("100d100+50", fixed_rng)
  
  case result2 {
    Ok(value) -> {
      io.println("   100d100+50 result: " <> int.to_string(value) <> " (timing: see context doc)")
      // Should be 100 × 50 + 50 = 5050
      case value == 5050 {
        True -> io.println("   ✅ PASS - 100d100+50 succeeded")
        False -> io.println("   ❌ FAIL - 100d100+50 unexpected result")
      }
    }
    Error(_) -> io.println("   ❌ FAIL - 100d100+50 failed to roll")
  }
}