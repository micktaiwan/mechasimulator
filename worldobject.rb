require 'ode'

class WorldObject
  
  attr_accessor :body
  
  def initialize(w,s)
    @world,@space = w,s
    @body = @world.createBody
    #mass = ODE::Mass
    #mass.
    #mass.adjust(1)
    #@body.mass = mass
    #puts @body.mass
    #puts @body.force
    @geom = ODE::Geometry::Box.new(0.5,0.5,0.5,@space)
    @geom.body = @body
    @body.position = [0.5,0,4]
  end
  
end
