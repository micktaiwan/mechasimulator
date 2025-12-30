require_relative 'vector'
require_relative 'particle'
require_relative 'collisions'

# helper class that respond to current
class FalseParticle < MVector
  def current
    self
  end
end

class Force
  attr_accessor :type, :values
  
  def initialize(p, t, v)
    @particle, @type, @values = p, t, v
    case @type
    when :motor
      @center = resolve(v[0])
      @normal = resolve(v[1])
      @length = v[2]
    when :gravit
      @toward = resolve(v[0])
      @opt = v[1]
    when :uni
      @cache = MVector.new(v[0],v[1],v[2])
    end
  end
  
  def vector
    case type
      when :uni
        @cache
      when :motor
        calculate_motor_force
      when :gravit
        calculate_gravit_force
      else
        raise "oops, type unknown: #{type}"
    end
  end
  
private
  
  def calculate_motor_force
    # (pos - center) x normale
    c = @center.current
    ((@particle.current - c).cross(@normal)).normalize * @length
  end
  
  def calculate_gravit_force
    v  = (@toward.current - @particle.current)
    l = v.length
    if @opt[:reverse]
      v *= (l*l)
    else
      v *= 1/(l*l) if(l > 0)
    end
    v *= @opt[:factor] if @opt[:factor]
    v
  end
  
  def resolve(v)
    if v.respond_to?(:current); return v
    else; return FalseParticle.new(v[0],v[1],v[2])
    end
  end
  
end

class Constraint

  attr_accessor :type,      # :fixed, :rod, :boundary
                :particles, # particle, or [p1, p2] (for rod)
                :value      # can be [x,y,z] (for fixed) or a distance (for rod) or a [coord, sup or inf, value] (for a boundary)
  
  def initialize(t,p,v)
    raise "rod for 2 particules with same position" if t==:rod and p[0].current == p[1].current
    @type, @particles, @value = t, p, v
  end
  
  def replace(old,new)
    if @particles.respond_to?(:current)
      @particles = new if @particles == old
    else
      @particles.each_index { |i|
        @particles[i] = new if @particles[i] == old
        }
    end
  end
  
  def add_length(value)
    return if type != :rod
    @value += value
  end 
  
  def boundary_component
    @value[0]
  end

  def boundary_comparator
    @value[1]
  end
  
  def boundary_value
    @value[2]
  end

  def boundary_stickiness
    @value[3] || 0.3  # default stickiness if not specified
  end

  def plane_axis
    @value[0]
  end

  def plane_value
    @value[1]
  end

end

# Spring: applies Hooke's law force between two particles
# Unlike rod (position constraint), spring applies forces proportional to stretch
class Spring
  attr_accessor :p1, :p2, :rest_length, :stiffness, :damping, :max_stretch

  # stiffness (k): force per unit stretch (N/m)
  # damping (c): velocity damping coefficient (optional)
  # max_stretch: maximum extension as multiplier of rest_length (e.g., 3.0 = 300%)
  #              beyond this, force becomes quadratic to prevent infinite stretching
  def initialize(p1, p2, rest_length, stiffness, damping = 0.0, max_stretch = 3.0)
    @p1 = p1
    @p2 = p2
    @rest_length = rest_length
    @stiffness = stiffness
    @damping = damping
    @max_stretch = max_stretch

    # Warn if both particles are fixed (spring will have no effect)
    if @p1.invmass == 0 && @p2.invmass == 0
      warn "Warning: Spring between two fixed particles has no effect"
    end
  end

  # Apply spring forces to both particles
  # F = -k * (length - rest_length) * direction
  # F_damping = -c * relative_velocity_along_spring
  def apply_forces(dt)
    delta = @p2.current - @p1.current
    length = delta.length
    return if length < 1e-8

    direction = delta / length
    stretch = length - @rest_length

    # Calculate max allowed length
    max_length = @rest_length * @max_stretch

    if length > max_length
      # Beyond max: quadratic force (much stronger to prevent infinite stretch)
      base_stretch = max_length - @rest_length
      overshoot = length - max_length
      force_magnitude = @stiffness * base_stretch + @stiffness * overshoot * overshoot * 10
    else
      # Normal Hooke's law: F = k * stretch
      force_magnitude = @stiffness * stretch
    end

    # Damping: relative velocity along spring direction
    if @damping > 0 && dt > 0
      v1 = (@p1.current - @p1.old) / dt
      v2 = (@p2.current - @p2.old) / dt
      relative_velocity = v2 - v1
      velocity_along_spring = relative_velocity.dot(direction)
      force_magnitude += @damping * velocity_along_spring
    end

    force = direction * force_magnitude

    # Apply equal and opposite forces (converted to acceleration)
    @p1.acc = @p1.acc + (force * @p1.invmass) if @p1.invmass > 0
    @p2.acc = @p2.acc - (force * @p2.invmass) if @p2.invmass > 0
  end
end

# A ParticleSystem object is just a set of particle with constraints
class PSObject

  attr_accessor :particles, :name

  def initialize(name)
    @name = name
    @particles = []
  end
  
  def <<(p)
    @particles << p
    p
  end
  
  def >>(p)
    @particles.delete(p)
  end
  
  def find_part_by_pos(arr)
    @particles.each { |p|
      return p if p.current.x==arr.first and p.current.y==arr[1] and p.current.z==arr.last
      }
  end
  
  def size
    @particles.size
  end
  
  def[](i)
    @particles[i]
  end
   
  
end

class ParticleSystem

  attr_accessor :time_step, :particles, :constraints, :springs

  def initialize(set_of_objects=[])
    @objects = set_of_objects
    @time_step = 1/60.0
    @dt_sub = 1/60.0/8  # Last substep dt used (for energy calculation)
    @gravity = MVector.new(0,0,-9.81)
    @num_substeps = CONFIG[:ps][:num_substeps] || 8
    # Small compliance for numerical stability (0 can cause oscillations)
    @compliance = CONFIG[:ps][:compliance] || 0.00001
    @particles    = []
    @constraints  = []
    @springs      = []
    @polys        = []
  end

  def clear
    @objects.clear
    @particles.clear
    @constraints.clear
    @springs.clear
    @polys.clear
    @num_substeps = CONFIG[:ps][:num_substeps] || 8
    @compliance = CONFIG[:ps][:compliance] || 0.00001
  end
  
  def <<(o)
    @objects << o
    o.particles.each   { |p| @particles   << p }
  end
  
  def[](i)
    @particles[i]
  end
  
  def next_step
    @dt_sub = @time_step / @num_substeps

    if @dt_sub <= 0 || @dt_sub.nan?
      puts "Invalid dt_sub: #{@dt_sub}, time_step=#{@time_step}, num_substeps=#{@num_substeps}"
      exit(1)
    end

    @num_substeps.times do |substep|
      # Recalculate forces each substep (important for springs!)
      accumulate_forces

      # Verlet integration for this substep
      verlet_substep(@dt_sub)

      # XPBD constraint solving (1 iteration per substep is enough)
      satisfy_constraints_xpbd(@dt_sub)

      detect_collisions if CONFIG[:ps][:collisions]
    end
  end
  
  # Add a constraint to the particle system
  # @param type [Symbol] constraint type (:rod, :fixed, :boundary, :plane)
  # @param particles [Array<Particle>, Particle, :all]
  #   - :rod requires [p1, p2] array
  #   - :fixed, :boundary, :plane require single particle (or :all)
  # @param values [Object, nil] constraint parameters (auto-calculated if nil for :rod/:fixed)
  def add_constraint(type, particles, values = nil)
    # Validate particles parameter based on constraint type
    if type == :rod
      raise ArgumentError, "rod constraint requires [p1, p2] array" unless particles.is_a?(Array) && particles.size == 2
    end

    if values.nil?
      # Set default values based on constraint type
      if type == :rod
        d = particles[0].current - particles[1].current
        values = Math.sqrt(d.dot(d))
      elsif type == :fixed
        values = particles.current.to_a
      end
    end
    
    if particles == :all
      @particles.each { |p|
        c = Constraint.new(type, p, values)
        @constraints << c
        }
    else
      c = Constraint.new(type, particles, values)
      @constraints << c
    end
    sort_constraints # didn't want to add a 'start' keyword or something to call the method optimize before the sim start
    c
  end
  
  alias :c :add_constraint
  
  def add_force(type, particles, values=nil)
     if particles == :all
      @particles.each { |p|
        p.add_force(type, values)
        }
    else
      particles.add_force(type, values)
    end
  end

  alias :f :add_force

  # Add a spring between two particles
  # stiffness: force per unit stretch (higher = stiffer)
  # damping: velocity damping (optional, reduces oscillation)
  # max_stretch: max extension as multiplier of rest_length (default: 3.0 = 300%)
  def add_spring(p1, p2, stiffness, damping = 0.0, rest_length = nil, max_stretch = 3.0)
    if rest_length.nil?
      d = p1.current - p2.current
      rest_length = Math.sqrt(d.dot(d))
    end
    s = Spring.new(p1, p2, rest_length, stiffness, damping, max_stretch)
    @springs << s
    s
  end
  
  def join(obj1, obj2, list)
    list.each { |arr|
      # verify that all particles in list are shared by obj1 and obj2
      p1 = obj1.find_part_by_pos(arr)
      p2 = obj2.find_part_by_pos(arr)
      raise "join particule not found in #{obj1.name}" if not p1
      raise "join particule not found in #{obj2.name}" if not p2
      # in obj2, replace p2 by p1
      obj2 >> p2
      obj2 << p1
      # in every constraint containing p2, replace p2 by p1
      @constraints.each { |c|
        c.replace(p2,p1)
        }
      # remove p2 from world
      @particles.delete(p2)
      # p2 forces are lost
      }
  end

  def add_poly(arr, stickiness = 0.3)
    @polys << Poly.new(arr, stickiness)
  end

  def find_object_by_name(name)
    @objects.select{|o| o.name == name}.first
  end
  
  def optimize
    sort_constraints
  end

  def total_energy
    ke = 0.0
    pe = 0.0
    g = 9.81
    dt = @dt_sub > 0 ? @dt_sub : @time_step / @num_substeps

    @particles.each do |p|
      next if p.invmass == 0  # skip fixed particles

      mass = 1.0 / p.invmass

      # Kinetic energy: 0.5 * m * v²
      # With XPBD substeps, (current - old) is velocity over one substep
      velocity = p.current - p.old
      v_squared = velocity.dot(velocity) / (dt * dt)
      ke += 0.5 * mass * v_squared

      # Potential energy: m * g * z
      pe += mass * g * p.current.z
    end

    { kinetic: ke, potential: pe, total: ke + pe }
  end

private

  def sort_constraints
    @constraints = @constraints.sort_by {|c|
      case c.type
      when :rod;      1
      when :boundary; 2
      when :plane;    3
      when :fixed;    4
      end
      }
  end

  # Verlet integration for a single substep
  def verlet_substep(dt)
    @particles.each_with_index do |p, i|
      next if p.invmass == 0  # skip fixed particles
      velocity = p.current - p.old

      # Save current position as old (in-place copy, zero allocation)
      p.old.copy_from(p.current)

      # Update position
      p.current = p.current + velocity + (p.acc * dt * dt)
    end
  end

  # accumulate forces for each particle
  def accumulate_forces
    @particles.each do |p|
      p.acc = MVector.new(0,0,0)
      p.forces.each do |f|
        case f.type
        when :gravity
          p.acc += @gravity
        else
          p.acc += f.vector
        end
      end
    end

    # Apply spring forces (Hooke's law)
    @springs.each do |s|
      s.apply_forces(@dt_sub)
    end
  end

  # XPBD constraint solving
  def satisfy_constraints_xpbd(dt)
    # Compliance term: α̃ = α / dt²
    # α = 0 means infinitely stiff (rigid), α > 0 means soft
    alpha_tilde = @compliance / (dt * dt)

    @constraints.each do |c|
      case c.type
      when :rod
        satisfy_rod_xpbd(c, alpha_tilde)
      when :boundary
        satisfy_boundary_xpbd(c)
      when :plane
        satisfy_plane_xpbd(c)
      when :fixed
        satisfy_fixed_xpbd(c)
      end
    end
  end

  # XPBD distance constraint
  def satisfy_rod_xpbd(c, alpha_tilde)
    p1, p2 = c.particles[0], c.particles[1]
    rest_length = c.value

    delta = p2.current - p1.current
    length = Math.sqrt(delta.dot(delta))
    return if length < 1e-8

    n = delta / length  # Unit direction
    constraint_error = length - rest_length  # C(x)

    w = p1.invmass + p2.invmass  # Sum of inverse masses
    return if w < 1e-8

    # XPBD formula: Δλ = C / (w + α̃)
    delta_lambda = constraint_error / (w + alpha_tilde)

    # Position corrections (only apply to non-fixed particles)
    if p1.invmass > 0
      p1.current = p1.current + (n * (delta_lambda * p1.invmass))
    end
    if p2.invmass > 0
      p2.current = p2.current - (n * (delta_lambda * p2.invmass))
    end
  end

  # Boundary constraint (e.g., z > 0) with optional bounce
  def satisfy_boundary_xpbd(c)
    p = c.particles
    axis = c.boundary_component
    comp = c.boundary_comparator
    limit = c.boundary_value
    stickiness = c.boundary_stickiness

    pos_val = p.current.component_value(axis)
    violated = (comp == :>) ? (pos_val < limit) : (pos_val > limit)
    return unless violated

    # Get velocity component along this axis
    velocity = p.current - p.old
    v_axis = velocity.component_value(axis)

    # Reflect velocity on this axis
    # Normal direction: +1 if comp is :> (floor), -1 if comp is :< (ceiling)
    normal_sign = (comp == :>) ? 1.0 : -1.0

    # Reflected velocity = -v_axis (bounce back)
    v_reflected = -v_axis

    # Apply stickiness: 0 = full bounce, 1 = full stop
    v_final = v_reflected * (1.0 - stickiness)

    # Position correction with small offset to avoid re-collision
    offset = normal_sign * 0.001
    p.current.component_set(axis, limit + offset)

    # Update old position for correct velocity (Verlet)
    p.old.component_set(axis, limit + offset - v_final)
  end

  # Plane constraint (lock one axis)
  def satisfy_plane_xpbd(c)
    p = c.particles
    axis = c.plane_axis
    target = c.plane_value

    p.current.component_set(axis, target)
  end

  # Fixed constraint
  def satisfy_fixed_xpbd(c)
    c.particles.current.from_a(c.value)
  end
  
  def detect_collisions
    # for each particle, find if a collision with a poly occurred
    # skipping the poly if the particle is already a part of it (done in collision.rb)
    @particles.each do |p|
      @polys.each do |poly|
        type, point, distance, ray = poly.collision?(p)
        next if not type

        # Incoming velocity (Verlet: velocity is implicit)
        velocity = p.current - p.old

        # Normalized surface normal
        n = poly.normalized_normal(:current)

        # Ensure normal points toward where particle came from (opposite to velocity)
        # If velocity and normal point same direction, flip normal
        if velocity.dot(n) > 0
          n = n * -1
        end

        # Normal component of velocity (now guaranteed negative since n points opposite to v)
        v_dot_n = velocity.dot(n)
        v_normal = n * v_dot_n

        # Reflect velocity: v_reflected = v - 2 * v_normal
        v_reflected = velocity - v_normal * 2

        # Apply stickiness: 0 = full bounce, 1 = full stop
        v_final = v_reflected * (1.0 - poly.stickiness)

        # Push particle slightly off surface (in direction of corrected normal)
        offset = n * 0.002

        # Update positions for Verlet integration
        p.current = point + offset
        p.old = point + offset - v_final
      end
    end
  end

end
