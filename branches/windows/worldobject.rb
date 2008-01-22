#require 'ode'

# cette classe ne sert a rien bordel alors quoi

class WorldObject
  
  attr_accessor :geom
  
  def initialize(w,s)
    @world,@space = w,s
#    @body = @world.createBody
#    @body.position = [1,1,2]
    #mass = ODE::Mass
    #mass.
    #mass.adjust(1)
    #@body.mass = mass
    #puts @body.mass
    #puts @body.force
    @geom = ODE::Box.new(1,1,1,@space)
#    @geom.body = @body
  end
  
end
