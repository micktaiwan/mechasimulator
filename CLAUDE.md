# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Rules

- **All code, comments, and documentation must be in English.**

## Project Overview

MechaSimulator is a 3D physics simulation engine in Ruby using Verlet integration. It simulates particle systems with constraints and forces, visualized in real-time using OpenGL. Users define simulations via a custom DSL in `objects.rb`.

## Running the Application

```bash
# Using Homebrew Ruby (recommended for modern macOS)
/opt/homebrew/opt/ruby/bin/ruby src/main.rb

# Or if Homebrew Ruby is in your PATH
ruby src/main.rb
```

### Dependencies

Install via Homebrew:
```bash
brew install ruby glfw
```

Install the Ruby gem:
```bash
/opt/homebrew/opt/ruby/bin/gem install opengl-bindings2
```

The `joystick` gem is optional for gamepad support.

## Architecture

### Core Physics (Verlet Integration)
- `src/particle_system.rb` - Main simulation engine: force accumulation, Verlet step, constraint satisfaction
- `src/particle.rb` - Particle with position (current/old for Verlet), mass, and forces
- `src/vector.rb` - `MVector` class for 3D vector math

### Constraint System
- **Rod**: Maintains fixed distance between particles (rigid constraint)
- **Fixed**: Locks particle position
- **Boundary**: Restricts particle to region (e.g., `z > 0`)
- **Plane**: Locks one axis to a constant value for 2D motion (e.g., `y = 0.5`)

### Force System
- **Gravity**: Global downward force (-9.81 on z)
- **Spring**: Elastic force between particles (Hooke's law: F = k × stretch)
- **Motor**: Rotational force around axis
- **Uni**: Constant unidirectional force
- **Gravit**: Particle-to-particle gravitational attraction

### Rendering & UI
- `src/world.rb` - Base OpenGL world class
- `src/main.rb` - Entry point, `PlaneWorld` class extending World, main loop
- `src/camera.rb` - Camera control and particle following
- `src/console.rb` - On-screen text output
- `src/openglmenu.rb` / `src/menu_config.rb` - Menu system

### Input & DSL
- `src/controls.rb` - Input-to-action mapping
- `src/joy.rb` - Joystick wrapper
- `src/dsl.rb` - DSL interpreter for `objects.rb`
- `objects.rb` - Current simulation definition (user-editable, at root)

## DSL Reference

Simulations are defined in `objects.rb` using these commands:

```ruby
object :name           # Start object definition
  p(x, y, z)           # Create particle, returns reference
  p(x, y, z, mass)     # Create particle with mass
  rod p1, p2           # Rigid distance constraint between particles
  rod :last_two        # Rigid constraint between last two particles
  spring p1, p2, k, c  # Elastic spring (k=stiffness, c=damping)
  fix p                # Fix particle position
  plane p, :y, 0.5     # Lock particle to plane y=0.5 (2D motion)
  boundary p, :z, :>, 0  # Constrain particle component
  gravity p            # Apply gravity to particle
  uni p, [x, y, z]     # Constant force on particle
  motor p, center, axis, power  # Rotational force
  gravit p, toward     # Gravitational attraction
  box(v1, v2)          # Create box between two corners
  surface a, b, c, d   # Define collision surface
end_object

# Outside objects:
gravity :all           # Apply gravity to all particles
boundary :all, :z, :>, 0  # Ground plane
follow p               # Camera follows particle
trace p                # Draw particle trajectory
control 'key', [objs], :method, value  # Map input to action
console "text"         # Display text
v(x, y, z)             # Create vector
find_particle(:obj, [x,y,z])  # Find particle by object name and position
join :obj1, :obj2, [x,y,z], ...  # Join objects at points
```

Particle references: `:first`, `:last`, `:last_two`, or numeric index.

## Key Controls

- **Enter**: Toggle edit mode (live reload on save)
- **Backspace**: Force reload `objects.rb`
- **Space**: Toggle constraint visualization
- **1**: Toggle camera follow
- **2**: Toggle force visualization
- **F1**: Toggle menu
- **Escape**: Exit
- **Mouse drag**: Rotate camera

## Configuration

Global settings in `config.rb` (`CONFIG` hash):
- `:draw` - Screen size (800x600), point size, visualization toggles
- `:ps` - Simulation speed factor, constraint iterations (`nb_iter`), collisions toggle
- `:cam` - Follow mode, rotation distance
- `:joy` - Joystick device path
- `:mouse` - Speed factor

## Development Workflow

1. Edit `objects.rb` with simulation definition
2. Run `ruby src/main.rb`
3. Press **Backspace** to reload changes, or use edit mode (**Enter**) for live reload
4. See `examples.txt` for DSL examples (excavator, pendulum, motors, etc.)

## Documentation

- `docs/XPBD.md` - XPBD algorithm explanation and implementation details
