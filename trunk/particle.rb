require 'vector'

class Particle

  attr_accessor :current, :old, :acc # 3D vectors
  attr_accessor :forces
  attr_reader   :invmass
  
  def initialize(x,y,z)
    c = MVector.new(x.to_f,y.to_f,z.to_f)
    @current, @old = c, c
    @acc = MVector.new(0,0,0)
    @invmass = 1
    @forces = []
  end
  
  def set_mass(m)
    @invmass = 1/m.to_f
  end
  
  def add_force(type, values)
    @forces << Force.new(self, type, values)
  end
  
  def direction
    @current-@old
  end

end

