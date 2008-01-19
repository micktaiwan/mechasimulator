require 'ode'

class WorldObject
  
  attr_accessor :body
  
  def initialize(w,s)
    @world,@space = w,s
    @body = @world.createBody
    @body.position = [1,1,2]
    #mass = ODE::Mass
    #mass.
    #mass.adjust(1)
    #@body.mass = mass
    #puts @body.mass
    #puts @body.force
    @geom = ODE::Geometry::Box.new(1,1,1,@space)
    @geom.body = @body
    puts @geom.position
  end
  
end
