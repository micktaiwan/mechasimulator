require 'ode'

class WorldObject
  
  attr_accessor :body
  
  def initialize(w,s)
    @world,@space = w,s
    @body = @world.createBody
    #mass = ODE::Mass::Box.new(1,1,1,1)
    #mass.adjust(1)
    #@body.mass = mass
    #puts @body.mass
    #puts @body.force
    @geom = ODE::Geometry::Box.new(1,1,1,@space)
    @geom.body = @body
    @body.position = [0,-10,0]
    puts "initial pos: #{@body.position}"
  end
  
  def handle_collision
    
  end
  
end
