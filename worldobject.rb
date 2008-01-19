require 'ode'

class WorldObject
  
  attr_accessor :body
  
  def initialize(w,s)
    @world,@space = w,s
    @body = @world.createBody
    @body.position = [1,1,4]
    #mass = ODE::Mass
    #mass.
    #mass.adjust(1)
    #@body.mass = mass
    #puts @body.mass
    #puts @body.force
    @geom = ODE::Geometry::Box.new(2,2,2,@space)
    @geom.body = @body
  end
  
end
