# helper class to simplify the definition language
require 'particle_system'

class DSL

  def initialize(ps, c, cs, cam)
    @ps, @console, @controls, @cam = ps, c, cs, cam
  end

  def reload
    @ps.clear_objects
    begin
      eval(File.read('objects.rb'))
      @console.push "#{@ps.particles.size} particules reloaded"
    rescue Exception => e
      @console.push "Error in the objects.rb file:\n*** #{e.message}"
      #raise
    end
  end
  
  def p(x,y,z,mass=1.0)
    p = Particle.new(x,y,z)
    p.set_mass(mass)
    @current_object << p
    p
  end

  def c(t,i,v=nil)
    @ps.c(t,i,v)
  end
  
  def f(t,p,v=nil)
    @current_object.f(t,p,v)
  end
  
  
  def object(name=nil)
    @current_object = PSObject.new(name)
  end

  def end_object
    @ps << @current_object
    @current_object = nil # so :first, :last, ... can not be used anymore
  end
  
  def gravity p
    p = resolve(p)
    @ps.f(:gravity, p)
  end
  
  def mass(value)
    @current_object.particles.each{ |p| p.set_mass(value) }
  end
  
  def fix p
    p = resolve(p)
    @ps.c(:fixed,p)
  end
  
  def string p1, p2=nil
    p1 = resolve(p1)
    if p2 == nil # p1 should be :last_two
      return nil if p1[0] == nil
      return @ps.c(:string,p1)
    else
      p2 = resolve(p2)
      return @ps.c(:string,[p1,p2])
    end
  end
  
  def boundary p, a, b, c
    p = resolve(p)
    @ps.c(:boundary,p,[a,b,c])
  end
  
  def console str
    @console.push str
  end
  
  def motor p, center, normal_vector, power
    p = resolve(p)
    center = resolve(center)
    @ps.f(:motor, p, [center,normal_vector,power])
  end

  def uni p, vector
    p = resolve(p)
    @ps.f(:uni, p, vector)
  end
  
  def gravit(p, toward, opt={})
    p = resolve(p)
    toward = resolve(toward)
    @ps.f(:gravit, p, [toward, opt])
  end
  
  def join name1, name2, *list
    l = []
    list.each { |x,y,z|
      l << [x,y,z]
      }
    @ps.join(@ps.find_object_by_name(name1),@ps.find_object_by_name(name2),l)
  end
  
  def control(*args)
    @controls << args
  end
  
  def find_particle(obj_name, pos)
    o = @ps.find_object_by_name(obj_name)
    o.find_part_by_pos(pos)
  end
  
  def follow p, opt=nil
    p = resolve(p)
    @cam.set_follow(p, :current, :direction, opt)
  end
  
  
  def v(x,y,z)
    MVector.new(x,y,z)
  end
  
  def attach(a,b,c,d)
    string a,b
    string b,c
    string c,d
    string d,a

    string a,c
    string b,d
  end

  def box(p1, p2)
    p1 = MVector.new.from_a(p1) if not p1.respond_to?(:cross)
    p2 = MVector.new.from_a(p2) if not p2.respond_to?(:cross)
    
    # bottom
    a = p(p1.x,p1.y,p1.z)
    b = p(p2.x,p1.y,p1.z)
    c = p(p2.x,p2.y,p1.z)
    d = p(p1.x,p2.y,p1.z)
    attach(a,b,c,d)

    # up
    e = p(p1.x,p1.y,p2.z)
    f = p(p2.x,p1.y,p2.z)
    g = p(p2.x,p2.y,p2.z)
    h = p(p1.x,p2.y,p2.z)
    attach(e,f,g,h)
    
    # left
    attach(a,e,h,d)
    
    # right
    attach(b,f,g,c)

    # front
    attach(a,b,e,f)

    # rear
    attach(d,c,g,h)
  end

  
private
  def resolve p
    o = @current_object ? @current_object : @ps
    return o[p] if p.class == Fixnum
    return o[0]  if p==:first
    return o[-1] if p==:last
    return [o[-2], o[-1]] if p==:last_two
    p    
  end

end
