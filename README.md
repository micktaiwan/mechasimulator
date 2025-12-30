# MechaSimulator

A 3D physics simulation engine written in Ruby, using Verlet integration for particle-based physics and OpenGL for real-time visualization.

## What is it?

MechaSimulator lets you build and simulate mechanical systems made of particles connected by constraints. Think of it like a virtual construction kit where you can create:

- Pendulums and swinging objects
- Articulated arms (like excavators)
- Soft bodies and cloth-like structures
- Flying objects with forces
- Any particle-based mechanical system

The physics engine uses **Verlet integration**, a numerical method that's simple yet stable for simulating particles with constraints.

## Personal Note

> It will never be finished, I know it, but here you will find a little fantasy of mine.
> Build a plane simulation, yeah, with forces and all. I am a big fan of Flight Simulator, this is my goal.
> Well my goal is actually to learn vectors, forces, OpenGL, that's all :)
> I think I may live 40 more years. So I still got time. :)

## Installation

### Requirements

- macOS with Homebrew (or Linux with appropriate packages)
- Ruby 4.0+ (via Homebrew recommended)
- GLFW library

### Setup

```bash
# Install Ruby and GLFW
brew install ruby glfw

# Install the OpenGL bindings gem
/opt/homebrew/opt/ruby/bin/gem install opengl-bindings2
```

## Running

```bash
/opt/homebrew/opt/ruby/bin/ruby src/main.rb
```

Or if Homebrew Ruby is in your PATH:
```bash
ruby src/main.rb
```

## Controls

| Input | Action |
|-------|--------|
| **Mouse drag** | Rotate camera |
| **Arrow keys** | Move camera |
| **Enter** | Toggle edit mode (pause + live reload) |
| **Backspace** | Force reload objects.rb |
| **Space** | Toggle constraint visualization |
| **1** | Toggle camera follow |
| **2** | Toggle force visualization |
| **f** | Toggle fullscreen |
| **F1** | Toggle menu |
| **Escape** | Exit |

## How It Works

### The Physics Engine

The simulator uses a particle system with three main components:

1. **Particles**: Points in 3D space with mass and position
2. **Constraints**: Rules that particles must follow (distances, boundaries, fixed positions)
3. **Forces**: Accelerations applied to particles (gravity, motors, custom forces)

Each simulation step:
1. Accumulate all forces on each particle
2. Update positions using Verlet integration: `new_pos = current + (current - old) + acceleration * dt²`
3. Satisfy constraints iteratively (adjust positions to maintain distances, boundaries, etc.)

### The DSL (Domain Specific Language)

Objects are defined in `objects.rb` using a Ruby-based DSL. The file is evaluated as Ruby code, so you have full programming power (loops, variables, methods).

## Creating Objects

### Basic Structure

```ruby
object :my_object          # Start defining an object (name is optional)
  # ... particles, constraints, forces ...
end_object                 # Finish the object definition
```

### Creating Particles

```ruby
p(x, y, z)                 # Create a particle at position (x, y, z)
p(x, y, z, mass)           # Create a particle with specific mass

# Particles return references you can store:
a = p(0, 0, 1)
b = p(1, 0, 1)
```

### Adding Constraints

```ruby
# Rod constraint (maintains fixed distance between particles, like a rigid rod)
rod a, b                   # Connect two particles
rod :last_two              # Connect the last two created particles

# Spring (elastic force - Hooke's law)
spring a, b, 100           # Spring with stiffness k=100
spring a, b, 100, 2.0      # Spring with stiffness k=100 and damping c=2.0

# Fixed constraint (locks a particle in place)
fix a                      # Fix particle 'a' at its current position
fix :first                 # Fix the first particle of the object

# Boundary constraint (restricts movement)
boundary a, :z, :>, 0      # Particle 'a' must have z > 0 (ground plane)
boundary :all, :z, :>, 0   # Apply to all particles

# Plane constraint (locks one axis for 2D motion)
plane a, :y, 0             # Particle 'a' moves only in XZ plane (y=0)
plane a, :x, 1.5           # Particle 'a' moves only in YZ plane (x=1.5)
```

### Adding Forces

```ruby
# Gravity (downward force)
gravity a                  # Apply gravity to particle 'a'
gravity :all               # Apply gravity to all particles

# Unidirectional force (constant force in a direction)
uni a, [0, 0, 9.81]        # Push particle 'a' upward (counteracts gravity)

# Motor (rotational force)
motor a, center, [0,1,0], power  # Rotate 'a' around 'center' on Y-axis

# Gravitational attraction
gravit a, b                # 'a' is attracted toward 'b'
```

### Particle References

Inside an object, you can reference particles by:
- Variable: `a`, `b`, `my_particle`
- Index: `0`, `1`, `2` (order of creation)
- Keywords: `:first`, `:last`, `:last_two`
- `:all` for applying to all particles

### Helper Functions

```ruby
v(x, y, z)                 # Create a vector
box(v1, v2)                # Create a box between two corner vectors
```

### Keyboard Controls

```ruby
control 'key', [objects], :method, value

# Examples:
control 'o', [spring1, spring2], :add_length, -0.01  # 'o' shortens springs
control 'p', [spring1, spring2], :add_length,  0.01  # 'p' lengthens springs
```

### Camera

```ruby
follow :last               # Camera follows the last particle
trace :last                # Draw trajectory of last particle
```

## Examples

### Simple Pendulum (with rod)

```ruby
object :pendulum
  fix p(0, 0, 2)           # Fixed point at top
  p(1, 0, 2)               # Swinging mass
  rod :last_two            # Connect them (rigid)
end_object

gravity :all
```

### Bouncy Pendulum (with spring)

```ruby
object :bouncy
  fix p(0, 0, 2)           # Fixed point at top
  p(1, 0, 2)               # Swinging mass
  spring :last_two, 100, 1 # Connect with spring (k=100, damping=1)
end_object

gravity :all
```

**Rod vs Spring:**
- **Rod**: Position constraint - maintains exact distance (rigid)
- **Spring**: Force - pulls particles together proportional to stretch (elastic, oscillates)

### Double Pendulum (Chaotic Motion)

```ruby
object :double_pendulum
  fix anchor = p(0, 0, 2)

  pend1 = p(0, 0, 1.5)
  rod anchor, pend1
  plane pend1, :y, 0       # Constrain to XZ plane

  pend2 = p(0, 0, 1)
  rod pend1, pend2
  plane pend2, :y, 0       # Constrain to XZ plane
end_object

gravity :all
trace pend2                # Visualize chaotic trajectory
```

### Chain / Necklace

```ruby
object :chain
  20.times do |i|
    p(i * 0.1, 0, 3)       # Create particles in a line
    rod :last_two          # Connect each to the previous
  end
  fix :first               # Fix the first particle
end_object

gravity :all
```

### Controllable Arm

```ruby
object :arm
  base = p(0, 0, 0)
  fix base
  tip = p(1, 0, 1)
  actuator = rod base, tip

  # Control with keyboard
  control 'o', [actuator], :add_length, -0.01
  control 'p', [actuator], :add_length,  0.01
end_object

gravity :all
boundary :all, :z, :>, 0   # Ground plane
```

### Flying Object

```ruby
object :flyer
  p(0, 0, 2)
  uni :last, [0, 0, 9.81 * 2]  # Upward force (2x gravity)
end_object

gravity :all
```

### Motor-Driven Rotation

```ruby
object :spinner
  center = p(0, 0, 2)
  fix center
  arm = p(1, 0, 2)
  rod center, arm
  motor arm, center, [0, 0, 1], 10  # Rotate around Z-axis
end_object

gravity :all
```

## Live Editing

1. Run the simulator: `ruby src/main.rb`
2. Press **Enter** to enable edit mode
3. Modify `objects.rb` in your text editor
4. Save the file - changes appear immediately!

Or press **Backspace** to force a reload at any time.

## Configuration

Edit `config.rb` to change:
- Screen resolution (`screen_width`, `screen_height`)
- Simulation speed (`speed_factor`)
- Constraint iterations (`nb_iter` - higher = more accurate but slower)
- Enable/disable collisions

## File Structure

| File | Purpose |
|------|---------|
| `src/main.rb` | Entry point, rendering, input handling |
| `objects.rb` | Your simulation definition (edit this!) |
| `config.rb` | Configuration |
| `src/dsl.rb` | DSL interpreter |
| `src/particle_system.rb` | Physics engine (XPBD) |
| `src/particle.rb` | Particle class |
| `src/vector.rb` | 3D vector math |
| `src/world.rb` | OpenGL setup |
| `examples.txt` | More DSL examples |

## Documentation

- [XPBD Algorithm](docs/XPBD.md) - Extended Position Based Dynamics implementation details

## License

Personal project - feel free to learn from it!
