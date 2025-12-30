require_relative 'vector'

class Particle

  attr_accessor :current, :old, :acc # 3D vectors
  attr_accessor :forces
  attr_reader   :invmass
  
  def initialize(x,y,z)
    # Create separate MVector objects for current and old (not same reference!)
    @current = MVector.new(x.to_f, y.to_f, z.to_f)
    @old = MVector.new(x.to_f, y.to_f, z.to_f)
    @acc = MVector.new(0,0,0)
    @invmass = 1
    @forces = []
  end
  
  def set_mass(m)
    @invmass = 1/m.to_f
  end

  def fix_mass
    @invmass = 0
  end
  
  def add_force(type, values)
    @forces << Force.new(self, type, values)
  end
  
  def direction
    @current-@old
  end

  def push_x(value)
    @current.x += value
  end

  def push_z(value)
    @current.z += value
  end

  # Compute velocity from Verlet state
  def velocity(dt)
    return MVector.new(0, 0, 0) if dt <= 0 || @invmass == 0
    (@current - @old) / dt
  end

  # Apply impulse by adjusting old position
  # impulse = delta_velocity / invmass
  def apply_impulse(impulse, dt)
    return if @invmass == 0
    delta_v = impulse * @invmass
    @old -= delta_v * dt
  end

  # Apply impulse along a single axis
  def apply_impulse_axis(axis, impulse_magnitude, dt)
    return if @invmass == 0
    delta_v = impulse_magnitude * @invmass
    @old.component_set(axis, @old.component_value(axis) - delta_v * dt)
  end

end

