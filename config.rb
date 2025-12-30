# Configuration file for MechaSimulator
# Reload the application to apply changes

CONFIG = {

  # Joystick configuration (optional, requires 'joystick' gem)
  :joy => {
    :dev => '/dev/input/js0',   # Device path (Linux)
    :factor => 32000.0          # Axis normalization factor
  },

  # Logging (not currently used)
  :log => {
    :joy   => nil,
    :pos   => nil,
    :event => nil,
    :collision => nil,
    :camera => nil,
    :debug => nil
  },

  # Mouse controls
  :mouse => {
    :speed_factor => 0.2        # Camera rotation sensitivity (lower = slower)
  },

  # Display settings
  :draw => {
    :screen_width => 800,       # Initial window width (ignored if fullscreen)
    :screen_height => 600,      # Initial window height (ignored if fullscreen)
    :point_size => 6,           # Particle rendering size in pixels
    :constraints => true,       # Show constraint lines (toggle with Space)
    :forces => false,           # Show force vectors (toggle with 2)
    :menu => false              # Show menu at startup (toggle with F1)
  },

  # Camera settings
  :cam => {
    :follow => true,            # Camera follows particle (toggle with 1)
    :rotate => 0,               # Auto-rotation distance, 0 = disabled
    :acceleration => 0.001,     # Speed boost per frame (when key held)
    :turn_speed => 0.015,         # Rotation degrees per frame (when key held)
    :friction => 0.94,          # Velocity damping (0.9-0.99, higher = more glide)
    # Key bindings (AZERTY default, change for QWERTY: w/s/a/d)
    :key_forward => 'z',
    :key_backward => 's',
    :key_strafe_left => 'q',
    :key_strafe_right => 'd'
  },

  # Particle system / physics
  :ps => {
    :speed_factor => 3,         # Time scale: 1 = realtime, 0.5 = 2x faster, 2 = 2x slower
    :nb_iter => 2,              # Constraint solver iterations per frame (2-20 typical)
                                # Higher = more accurate but slower
                                # Only affects simulations with constraints (string, fix, boundary)
    :collisions => true         # Enable collision detection (nil or true)
  }

}
