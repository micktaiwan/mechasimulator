require_relative 'vector'
require_relative 'particle'
require_relative 'collisions'

# helper class that respond to current
class FalseParticule < MVector
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
        raise "ooops, type uknown: #{type}"
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
    else; return FalseParticule.new(v[0],v[1],v[2])
    end
  end
  
end

class Constraint

  attr_accessor :type,      # :fixed, :string, :boundary
                :particles, # particle, or [p1, p2] (for string)
                :value      # can be [x,y,z] (for fixed) or a distance (for string) or a [coord, sup or inf, value] (for a boundary)
  
  def initialize(t,p,v)
    raise "string for 2 particules with same position" if t==:string and p[0].current == p[1].current
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
    return if type != :string
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

  def plane_axis
    @value[0]
  end

  def plane_value
    @value[1]
  end

end

#class CString < Constraint
#end

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

  attr_accessor :time_step, :particles, :constraints

  def initialize(set_of_objects=[])
    @objects = set_of_objects
    @time_step = 1/60.0
    @time_step_prev = 1/60.0
    @gravity = MVector.new(0,0,-9.81)
    @nb_iter = CONFIG[:ps][:nb_iter]
    @particles    = []
    @constraints  = []    
    @polys        = []
  end
  
  def clear
    @objects.clear
    @particles.clear
    @constraints.clear
    @polys.clear
    @nb_iter = CONFIG[:ps][:nb_iter]
  end
  
  def <<(o)
    @objects << o
    o.particles.each   { |p| @particles   << p }
  end
  
  def[](i)
    @particles[i]
  end
  
  def next_step
    accumulate_forces
    verlet
    @nb_iter.times do
      satisfy_constraints
      detect_collisions if CONFIG[:ps][:collisions]
    end
  end
  
  def add_constraint(type,particles,values=nil)
  
    if values == nil
      # set some default values
      if type == :string
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

  def add_poly(arr)
    @polys << Poly.new(arr)
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
    dt = @time_step_prev > 0 ? @time_step_prev : @time_step

    @particles.each do |p|
      next if p.invmass == 0  # skip fixed particles

      mass = 1.0 / p.invmass

      # Kinetic energy: 0.5 * m * v²
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
      when :string;   1
      when :boundary; 2
      when :plane;    3
      when :fixed;    4
      end
      }
  end
   
  # Time-Corrected Verlet integration step
  def verlet
    dt = @time_step
    dt_prev = @time_step_prev
    dt_ratio = dt_prev > 0 ? dt / dt_prev : 1.0

    @particles.each do |p|
      next if p.invmass == 0  # skip fixed particles
      velocity = (p.current - p.old) * dt_ratio
      new_pos = p.current + velocity + (p.acc * dt * dt)
      p.old = p.current
      p.current = new_pos
    end

    @time_step_prev = dt
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
  end
  
  # Here constraints are satisfied
  def satisfy_constraints
    @constraints.each do |c| # sorted by strings, boundaries, fixed
      case c.type
      when :string
        p1, p2 = c.particles[0], c.particles[1]
        restlength = c.value
        delta = p2.current - p1.current
        deltalength = Math.sqrt(delta.dot(delta))
        diff = (deltalength-restlength) / (deltalength*(p1.invmass+p2.invmass))
        p1.current += delta*(diff*p1.invmass);
        p2.current -= delta*(diff*p2.invmass);
      when :boundary
        p = c.particles
        # read: p.current.z = 0 if not p.current.z > 0
        p.current.component_set(c.boundary_component,c.boundary_value) if not p.current.component_value(c.boundary_component).send(c.boundary_comparator, c.boundary_value)
      when :plane
        p = c.particles
        p.current.component_set(c.plane_axis, c.plane_value)
        p.old.component_set(c.plane_axis, c.plane_value)
      when :fixed
        c.particles.current.from_a(c.value)
      end # case
    end # constraints
  end # function
  
  def detect_collisions
    # for each particle, find if a collision with a poly occurred
    # skipping the poly if the particle is already a part of it (done in collision.rb)
    @particles.each { |p|
      @polys.each { |poly|
        type, point, distance, ray = poly.collision?(p)
        next if not type
        # we have a collision !
        # p is moved
        tmp = p.current
        p.current = point
        p.old = tmp
        # poly is moved
        #move_poly(poly, point, distance, ray)
        }
      }
  end
  
  def move_poly(poly, point, distance, ray)
    poly.particles.each { |p|
      #print p.current, "=>"
      p.current = p.old
      #puts p.current
      }
  end
  
end
