# Physics DSL Feature Zoo
# A demonstration of all DSL capabilities organized in a 4x4 grid
# Navigate with camera: mouse drag to rotate, scroll to zoom

# ============================================================
# HELPER: Create exhibit boundary (visible fence at ground level)
# ============================================================
def exhibit_boundary(name, cx, cy, size = 1.4)
  object name
    h = 0.05  # Slightly above ground for visibility
    bl = p(cx - size, cy - size, h)
    br = p(cx + size, cy - size, h)
    tr = p(cx + size, cy + size, h)
    tl = p(cx - size, cy + size, h)
    fix bl; fix br; fix tr; fix tl
    rod bl, br
    rod br, tr
    rod tr, tl
    rod tl, bl
  end_object
end

# ============================================================
# EXHIBIT 0: ENTRANCE (0, 0) - Welcome area
# ============================================================
exhibit_boundary(:entrance, 0, 0)

object :welcome_sign
  # Simple vertical post
  base = p(0, 0, 0.1)
  top = p(0, 0, 1.5)
  fix base
  rod base, top
end_object

# ============================================================
# EXHIBIT 1: GRAVITY (4, 0) - Falling particles
# ============================================================
exhibit_boundary(:exhibit_gravity, 4, 0)

object :gravity_demo
  # Particles at different heights - will fall
  p(3.6, -0.3, 3.0)
  p(4.0, 0.0, 4.0)
  p(4.4, 0.3, 5.0)
end_object

# ============================================================
# EXHIBIT 2: COMBINED (8, 0) - Motor + Spring + Trace
# ============================================================
exhibit_boundary(:exhibit_combined, 8, 0)

object :combined_demo
  # Fixed base with rotating arm
  center = p(8, 0, 1.0)
  fix center

  # Rotating arm
  arm_end = p(8.8, 0, 1.0)
  rod center, arm_end
  motor arm_end, center, [0, 0, 1], 8

  # Spring-loaded pendulum hanging from arm
  # max_stretch: 2.0 = max 200% extension to prevent infinite stretch under centrifugal force
  bob = p(8.8, 0, 0.3)
  spring arm_end, bob, 80, 3, max_stretch: 2.0
end_object

trace find_particle(:combined_demo, [8.8, 0, 0.3]), step: 2, max: 300, join: true

# ============================================================
# EXHIBIT 3: FOLLOW (12, 0) - Camera follow demo
# ============================================================
exhibit_boundary(:exhibit_follow, 12, 0)

object :follow_demo
  # Swinging pendulum to follow
  anchor = p(12, 0, 2.5)
  fix anchor

  bob = p(13, 0.5, 1.5)
  rod anchor, bob
end_object

# follow find_particle(:follow_demo, [13, 0.5, 1.5])  # Uncomment to enable

# ============================================================
# EXHIBIT 4: ROD (0, 4) - Rigid chain/pendulum
# ============================================================
exhibit_boundary(:exhibit_rod, 0, 4)

object :rod_chain
  # Fixed anchor point
  anchor = p(0, 4, 2.5)
  fix anchor

  # Chain of particles connected by rods
  8.times do |i|
    p(0.2 * (i + 1), 4, 2.5 - 0.25 * (i + 1))
    rod :last_two
  end
end_object

# ============================================================
# EXHIBIT 5: SPRING (4, 4) - Elastic oscillation
# ============================================================
exhibit_boundary(:exhibit_spring, 4, 4)

object :spring_demo
  # Stiff spring (left)
  top1 = p(3.5, 4, 2.5)
  fix top1
  mass1 = p(3.5, 4, 1.2)
  spring top1, mass1, 150, 2  # k=150 (stiff), c=2

  # Soft spring (right)
  top2 = p(4.5, 4, 2.5)
  fix top2
  mass2 = p(4.5, 4, 1.2)
  spring top2, mass2, 40, 1  # k=40 (soft), c=1
end_object

# Control: Y/H to modify spring stiffness
# control 'y', [spring objects], :stiffness, +10
# control 'h', [spring objects], :stiffness, -10

# ============================================================
# EXHIBIT 6: FIX (8, 4) - Fixed pivot point
# ============================================================
exhibit_boundary(:exhibit_fix, 8, 4)

object :fix_demo
  # Triangle with one fixed vertex
  a = p(8, 3.5, 0.5)
  b = p(8.6, 4.5, 0.5)
  c = p(7.4, 4.5, 0.5)

  rod a, b
  rod b, c
  rod c, a

  # Only fix point A - triangle swings around it
  fix a
end_object

# ============================================================
# EXHIBIT 7: BOUNDARY (12, 4) - Invisible walls
# ============================================================
exhibit_boundary(:exhibit_boundary, 12, 4)

object :boundary_demo
  # Ball bouncing in an invisible box
  ball = p(12, 4, 1.5, 0.5)  # Light mass for bouncier effect

  # Invisible walls (boundaries)
  boundary ball, :x, :>, 10.7
  boundary ball, :x, :<, 13.3
  boundary ball, :y, :>, 2.7
  boundary ball, :y, :<, 5.3
  boundary ball, :z, :>, 0.2

  # Give it some initial push
  uni ball, [3, 2, 0]
end_object

# ============================================================
# EXHIBIT 8: PLANE (0, 8) - 2D motion constraint
# ============================================================
exhibit_boundary(:exhibit_plane, 0, 8)

object :plane_demo
  # Pendulum locked to Y=8 plane (2D motion in XZ only)
  anchor = p(0, 8, 2.5)
  fix anchor

  # Chain constrained to single plane
  prev = anchor
  5.times do |i|
    curr = p(0.3 * (i + 1), 8, 2.5 - 0.3 * (i + 1))
    rod prev, curr
    plane curr, :y, 8  # Lock Y coordinate
    prev = curr
  end
end_object

# ============================================================
# EXHIBIT 9: UNI (4, 8) - Constant directional force
# ============================================================
exhibit_boundary(:exhibit_uni, 4, 8)

object :uni_demo
  # Hovering particle (force exactly counters gravity)
  hover = p(4, 8, 1.0)
  uni hover, [0, 0, 9.81]  # Counters gravity = hovers
  boundary hover, :z, :>, 0.1

  # Particle with diagonal thrust
  thrust = p(4.5, 7.5, 0.5)
  uni thrust, [0, 0, 15]  # Upward thrust > gravity = rises
  boundary thrust, :z, :>, 0.1
  boundary thrust, :z, :<, 2.5
end_object

# ============================================================
# EXHIBIT 10: MOTOR (8, 8) - Rotational force
# ============================================================
exhibit_boundary(:exhibit_motor, 8, 8)

object :motor_demo
  # Fixed center
  center = p(8, 8, 1.2)
  fix center

  # Rotating arm with two ends
  arm1 = p(8.8, 8, 1.2)
  arm2 = p(7.2, 8, 1.2)

  rod center, arm1
  rod center, arm2

  # Motor force spins the arms around Z axis
  motor arm1, center, [0, 0, 1], 12
  motor arm2, center, [0, 0, 1], 12
end_object

# Control: T/G to modify motor power (would need rod reference)

# ============================================================
# EXHIBIT 11: TRACE (12, 8) - Trajectory visualization
# ============================================================
exhibit_boundary(:exhibit_trace, 12, 8)

object :trace_demo
  # Swinging pendulum with visible trace
  anchor = p(12, 8, 2.5)
  fix anchor

  bob = p(12.8, 8.3, 1.5)
  rod anchor, bob
end_object

# Enable trace on the pendulum bob
trace find_particle(:trace_demo, [12.8, 8.3, 1.5]), step: 3, max: 200, join: true

# ============================================================
# EXHIBIT 12: GRAVIT (0, 12) - Particle attraction
# ============================================================
exhibit_boundary(:exhibit_gravit, 0, 12)

object :gravit_demo
  # Central "sun" (fixed)
  sun = p(0, 12, 1.0)
  fix sun

  # Orbiting "planets"
  planet1 = p(0.9, 12, 1.0)
  planet2 = p(-0.7, 12.5, 1.0)
  planet3 = p(0.3, 11.3, 1.0)

  # Gravitational attraction toward sun
  gravit planet1, sun, factor: 0.8
  gravit planet2, sun, factor: 0.8
  gravit planet3, sun, factor: 0.8

  # Keep them in XY plane at this height
  plane planet1, :z, 1.0
  plane planet2, :z, 1.0
  plane planet3, :z, 1.0

  # Initial "orbital" velocities
  uni planet1, [0, 3, 0]
  uni planet2, [2, -1, 0]
  uni planet3, [-1.5, 2, 0]
end_object

# ============================================================
# EXHIBIT 13: BOX (4, 12) - 3D box geometry
# ============================================================
exhibit_boundary(:exhibit_box, 4, 12)

object :box_demo
  # Create a 3D box that falls
  box v(3.6, 11.6, 2.0), v(4.4, 12.4, 2.8)
end_object

# ============================================================
# EXHIBIT 14: SURFACE (8, 12) - Collision polygon/ramp
# ============================================================
exhibit_boundary(:exhibit_surface, 8, 12)

object :ramp_demo
  # Fixed ramp structure - inclined plane
  # Low edge (Y=11.5, Z=0.2)
  r1 = p(7.3, 11.5, 0.2)
  r2 = p(8.7, 11.5, 0.2)
  # High edge (Y=12.5, Z=1.5)
  r3 = p(8.7, 12.5, 1.5)
  r4 = p(7.3, 12.5, 1.5)

  fix r1; fix r2; fix r3; fix r4

  # Structural rods
  rod r1, r2
  rod r2, r3
  rod r3, r4
  rod r4, r1
  rod r1, r3  # Cross brace
  rod r2, r4  # Cross brace

  # Collision surface - vertex order determines normal direction
  # Counter-clockwise when viewed from above = normal points up
  # stickiness: 0.0 = full bounce, 1.0 = no bounce
  surface r1, r4, r3, r2, stickiness: 0.2
end_object

object :ball_on_ramp
  # Ball starting above the high end of the ramp
  p(8.0, 12.3, 2.5)
end_object

# ============================================================
# EXHIBIT 15: JOIN (12, 12) - Connected objects
# ============================================================
exhibit_boundary(:exhibit_join, 12, 12)

object :arm_lower
  # Lower arm segment
  base = p(12, 12, 0.2)
  fix base

  p1 = p(12.5, 12, 0.2)
  p2 = p(12.5, 12, 0.8)
  p3 = p(12, 12, 0.8)

  rod base, p1
  rod p1, p2
  rod p2, p3
  rod p3, base
  rod base, p2  # Cross brace
  rod p1, p3    # Cross brace
end_object

object :arm_upper
  # Upper arm segment (will be joined)
  q1 = p(12.5, 12, 0.8)  # Same position as p2
  q2 = p(12, 12, 0.8)    # Same position as p3
  q3 = p(12, 12, 1.5)
  q4 = p(12.5, 12, 1.5)

  rod q1, q2
  rod q2, q3
  rod q3, q4
  rod q4, q1
  rod q1, q3  # Cross brace
  rod q2, q4  # Cross brace
end_object

# Join the two arm segments at shared positions
join :arm_lower, :arm_upper, [12.5, 12, 0.8], [12, 12, 0.8]

# ============================================================
# GLOBAL SETTINGS
# ============================================================

# Apply gravity to all particles
gravity :all

# Global ground plane (stickiness: 0 = trampoline, 1 = sticky)
boundary :all, :z, :>, 0, stickiness: 0.3

# ============================================================
# CONSOLE: Instructions
# ============================================================
console "=== PHYSICS DSL ZOO ==="
console "Mouse drag: Rotate | Scroll: Zoom"
console "Space: Show constraints | 2: Show forces"
console "Backspace: Reload | Enter: Edit mode"
console ""
console "16 exhibits demonstrating all DSL features"
console "Explore: gravity, rod, spring, fix, plane,"
console "boundary, uni, motor, gravit, box, surface,"
console "join, trace, follow, control"
