#!/usr/bin/env ruby
# Performance tests for MechaSimulator optimizations
# Usage: /opt/homebrew/opt/ruby/bin/ruby test/perf_test.rb

require 'benchmark'
require_relative '../src/vector'

ITERATIONS = 500_000

def separator
  puts "-" * 60
end

def print_result(name, time_before, time_after)
  speedup = time_before / time_after
  improvement = ((1 - time_after / time_before) * 100).round(1)

  puts "#{name}:"
  puts "  Before: #{(time_before * 1000).round(2)} ms"
  puts "  After:  #{(time_after * 1000).round(2)} ms"
  puts "  Speedup: #{speedup.round(2)}x (#{improvement}% faster)"
  puts
end

# =============================================================================
# Test 1: MVector copy vs new()
# =============================================================================
def test_vector_copy
  puts "Test 1: MVector allocation (#{ITERATIONS} iterations)"
  puts "  Simulates: p.old = MVector.new(p.current.x, p.current.y, p.current.z)"

  v = MVector.new(1.5, 2.5, 3.5)
  target = MVector.new(0, 0, 0)

  # BEFORE: MVector.new() each time (current code)
  time_before = Benchmark.measure {
    ITERATIONS.times { MVector.new(v.x, v.y, v.z) }
  }.real

  # AFTER: copy() method (same allocation, but cleaner)
  time_copy = if v.respond_to?(:copy)
    Benchmark.measure { ITERATIONS.times { v.copy } }.real
  else
    puts "  [copy() not implemented yet - skipping]"
    time_before
  end

  # AFTER: copy_from() method (zero allocation, reuses target)
  time_copy_from = if v.respond_to?(:copy_from)
    Benchmark.measure { ITERATIONS.times { target.copy_from(v) } }.real
  else
    puts "  [copy_from() not implemented yet - skipping]"
    time_before
  end

  { before: time_before, copy: time_copy, copy_from: time_copy_from }
end

# =============================================================================
# Test 2: Console insert(0) vs push()
# =============================================================================
def test_console_insert
  puts "Test 2: Console queue operations (#{ITERATIONS} iterations)"
  puts "  Simulates: @queue.insert(0, msg) vs @queue.push(msg)"

  # BEFORE: insert(0) + pop (current code)
  queue_before = []
  time_before = Benchmark.measure {
    ITERATIONS.times { |i|
      queue_before.insert(0, "msg #{i}")
      queue_before.pop if queue_before.size > 7
    }
  }.real

  # AFTER: push() + shift
  queue_after = []
  time_after = Benchmark.measure {
    ITERATIONS.times { |i|
      queue_after.shift if queue_after.size >= 7
      queue_after.push("msg #{i}")
    }
  }.real

  print_result("Console queue", time_before, time_after)
  { before: time_before, after: time_after }
end

# =============================================================================
# Test 3: CONFIG hash lookup vs cached value
# =============================================================================
def test_config_lookup
  puts "Test 3: CONFIG hash lookup (#{ITERATIONS} iterations)"
  puts "  Simulates: CONFIG[:cam][:acceleration] vs @cached_value"

  # Simulate CONFIG hash
  config = {
    cam: {
      acceleration: 0.5,
      turn_speed: 0.1,
      follow: true
    }
  }

  # BEFORE: nested hash lookup each time
  time_before = Benchmark.measure {
    ITERATIONS.times {
      _ = config[:cam][:acceleration]
      _ = config[:cam][:turn_speed]
      _ = config[:cam][:follow]
    }
  }.real

  # AFTER: cached in local variable
  cached_accel = config[:cam][:acceleration]
  cached_turn = config[:cam][:turn_speed]
  cached_follow = config[:cam][:follow]

  time_after = Benchmark.measure {
    ITERATIONS.times {
      _ = cached_accel
      _ = cached_turn
      _ = cached_follow
    }
  }.real

  print_result("CONFIG lookup", time_before, time_after)
  { before: time_before, after: time_after }
end

# =============================================================================
# Test 4: Full Verlet substep simulation
# =============================================================================
def test_verlet_substep_simulation
  puts "Test 4: Simulated Verlet substep (100 particles x 1000 frames)"
  puts "  Simulates: the hot loop in particle_system.rb"

  particles = 100
  frames = 1000

  # Create mock particle data
  currents = Array.new(particles) { MVector.new(rand, rand, rand) }
  olds = Array.new(particles) { MVector.new(rand, rand, rand) }
  accs = Array.new(particles) { MVector.new(0, -9.81, 0) }
  dt = 0.016

  # BEFORE: MVector.new() in loop
  time_before = Benchmark.measure {
    frames.times {
      particles.times { |i|
        velocity = currents[i] - olds[i]
        olds[i] = MVector.new(currents[i].x, currents[i].y, currents[i].z)
        currents[i] = currents[i] + velocity + (accs[i] * dt * dt)
      }
    }
  }.real

  # Reset
  currents = Array.new(particles) { MVector.new(rand, rand, rand) }
  olds = Array.new(particles) { MVector.new(rand, rand, rand) }

  # AFTER: copy_from() if available
  if olds[0].respond_to?(:copy_from)
    time_after = Benchmark.measure {
      frames.times {
        particles.times { |i|
          velocity = currents[i] - olds[i]
          olds[i].copy_from(currents[i])
          currents[i] = currents[i] + velocity + (accs[i] * dt * dt)
        }
      }
    }.real
    print_result("Verlet substep", time_before, time_after)
    { before: time_before, after: time_after }
  else
    puts "  [copy_from() not implemented yet]"
    puts "  Before: #{(time_before * 1000).round(2)} ms"
    puts
    { before: time_before, after: time_before }
  end
end

# =============================================================================
# Main
# =============================================================================
puts "=" * 60
puts "MechaSimulator Performance Tests"
puts "=" * 60
puts

results = {}

separator
results[:vector] = test_vector_copy
separator
results[:console] = test_console_insert
separator
results[:config] = test_config_lookup
separator
results[:verlet] = test_verlet_substep_simulation
separator

puts
puts "=" * 60
puts "SUMMARY"
puts "=" * 60

if results[:vector][:copy_from] != results[:vector][:before]
  speedup = results[:vector][:before] / results[:vector][:copy_from]
  puts "MVector copy_from: #{speedup.round(2)}x faster"
end

if results[:console][:after] != results[:console][:before]
  speedup = results[:console][:before] / results[:console][:after]
  puts "Console push:      #{speedup.round(2)}x faster"
end

if results[:config][:after] != results[:config][:before]
  speedup = results[:config][:before] / results[:config][:after]
  puts "CONFIG cache:      #{speedup.round(2)}x faster"
end

if results[:verlet][:after] != results[:verlet][:before]
  speedup = results[:verlet][:before] / results[:verlet][:after]
  puts "Verlet substep:    #{speedup.round(2)}x faster"
end
