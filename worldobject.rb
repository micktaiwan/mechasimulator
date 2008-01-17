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
    @geom = ODE::Geometry::Box.new(2,2,2,@space)
    @geom.body = @body
    @body.position = [-1,-1,4]
    puts "initial body pos: #{@body.position}"
  end
  
end
