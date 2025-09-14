import dice_trio
import gleam/io
import gleamy/bench

pub fn main() {
  io.println("🎲 dice_trio Performance Benchmarks")
  io.println("===================================")

  simple_roll_benchmark()
  complex_expression_benchmark()
  extreme_load_benchmark()
  large_dice_expression_benchmark()
  extreme_boundary_conditions_benchmark()
  negative_results_benchmark()
  detailed_roll_performance_benchmark()
  io.println("\n✅ All benchmarks completed successfully!")
}

fn simple_roll_benchmark() {
  // Timing history: 2025-09-13: ~220k IPS (~0.0038s min), [previous], [previous]
  io.println("\n📊 Simple Roll Benchmark (1000 × d6)")
  let fixed_rng = fn(_) { 3 }

  bench.run(
    [bench.Input("d6", "d6")],
    [bench.Function("roll", fn(expr) { dice_trio.roll(expr, fixed_rng) })],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
  |> io.println()
}

fn complex_expression_benchmark() {
  // Timing history: 2025-09-13: ~165k IPS (~0.0050s min), [previous], [previous]
  io.println("\n📊 Complex Expression Benchmark (100 × 10d20+15)")
  let fixed_rng = fn(_) { 5 }

  bench.run(
    [bench.Input("10d20+15", "10d20+15")],
    [bench.Function("roll", fn(expr) { dice_trio.roll(expr, fixed_rng) })],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
  |> io.println()
}

fn extreme_load_benchmark() {
  // Timing history: 2025-09-13: 1000d6: ~31k IPS (~0.0308s min), 100d100+50: ~117k IPS (~0.0074s min), [previous], [previous]
  io.println("\n📊 Extreme Load Benchmark (1000d6, 100d100+50)")
  let fixed_rng = fn(max) { max / 2 }

  bench.run(
    [
      bench.Input("1000d6", "1000d6"),
      bench.Input("100d100+50", "100d100+50"),
    ],
    [bench.Function("roll", fn(expr) { dice_trio.roll(expr, fixed_rng) })],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
  |> io.println()
}

fn large_dice_expression_benchmark() {
  // Timing history: 2025-09-13: ~123k IPS (~0.0072s min), [previous], [previous]
  io.println("\n📊 Large Dice Expression Benchmark (100d100+50)")
  let fixed_rng = fn(_) { 50 }

  bench.run(
    [bench.Input("100d100+50", "100d100+50")],
    [bench.Function("roll", fn(expr) { dice_trio.roll(expr, fixed_rng) })],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
  |> io.println()
}

fn extreme_boundary_conditions_benchmark() {
  // Timing history: 2025-09-13: d1: ~222k IPS (~0.0038s min), 1000d6: ~32k IPS (~0.0297s min), [previous], [previous]
  io.println("\n📊 Extreme Boundary Conditions Benchmark")
  let max_rng = fn(max) { max }

  bench.run(
    [
      bench.Input("d1", "d1"),
      bench.Input("d1000", "d1000"),
      bench.Input("1000d6", "1000d6"),
    ],
    [bench.Function("roll", fn(expr) { dice_trio.roll(expr, max_rng) })],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
  |> io.println()
}

fn negative_results_benchmark() {
  // Timing history: 2025-09-13: d6-10: ~183k IPS (~0.0046s min), 2d6-20: ~176k IPS (~0.0048s min), [previous], [previous]
  io.println("\n📊 Negative Results Benchmark")
  let min_rng = fn(_) { 1 }

  bench.run(
    [bench.Input("d6-10", "d6-10"), bench.Input("2d6-20", "2d6-20")],
    [bench.Function("roll", fn(expr) { dice_trio.roll(expr, min_rng) })],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
  |> io.println()
}

fn detailed_roll_performance_benchmark() {
  // Timing history: 2025-09-13: d6: ~217k IPS (~0.0039s min), 10d6: ~202k IPS (~0.0042s min), 100d6+50: ~115k IPS (~0.0075s min), [previous], [previous]
  io.println("\n📊 DetailedRoll Performance Benchmark")
  let fixed_rng = fn(_) { 3 }

  bench.run(
    [
      bench.Input("d6", "d6"),
      bench.Input("10d6", "10d6"),
      bench.Input("100d6+50", "100d6+50"),
    ],
    [bench.Function("detailed_roll", fn(expr) { dice_trio.detailed_roll(expr, fixed_rng) })],
    [bench.Duration(1000), bench.Warmup(100)],
  )
  |> bench.table([bench.IPS, bench.Min, bench.P(99)])
  |> io.println()
}
