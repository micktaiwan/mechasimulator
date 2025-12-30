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
    :axes => false,             # Show 3D reference axes (X=red, Y=green, Z=blue)
    :menu => false              # Show menu at startup (toggle with F1)
  },

  # Camera settings
  :cam => {
    :follow => true,            # Camera follows particle (toggle with 1)
    :rotate => 0,               # Auto-rotation distance, 0 = disabled
    :acceleration => 0.005,     # Speed boost per frame (when key held)
    :turn_speed => 0.05,          # Rotation degrees per frame (when key held)
    :friction => 0.97,          # Velocity damping (0.9-0.99, higher = more glide)
    # Key bindings (AZERTY default, change for QWERTY: w/s/a/d)
    :key_forward => 'z',
    :key_backward => 's',
    :key_strafe_left => 'q',
    :key_strafe_right => 'd',
    :key_pitch_down => 'a',
    :key_pitch_up => 'e'
  },

  # Particle system / physics (XPBD)
  :ps => {
    :speed_factor => 1,         # Time scale: 1 = realtime, 0.5 = 2x faster, 2 = 2x slower
    :num_substeps => 16,        # Number of substeps per frame (more = better stability)
                                # More substeps = better energy conservation & stability
    :compliance => 0,     # Constraint compliance: 0 = rigid (can oscillate),
                                # > 0 = slightly soft (better stability, e.g., 0.00001)
    :collisions => true         # Enable collision detection (nil or true)
  }

}
