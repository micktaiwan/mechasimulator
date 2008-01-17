require 'vector'

class Camera
  
  attr_accessor :pos, :view, :rot
  
  def initialize
    #@pos  = MVector.new(584,263,510)
    #@view = MVector.new(769,347,686)
    
    @pos  = MVector.new(0,0,10)
    @view = MVector.new(0,0,0)
    @rot  = MVector.new(0,1,0)
  end
  
  
  # the cam moves forward (following its view) with the z parameter
  # the view is moved with parameters x and y  
  def move(x,y,z)
    
    puts "cam: pos: #{pos} view: #{view} rot: #{rot}" if (x!=0 or y!=0 or z!=0) and CONFIG[:log][:camera]
    
    # rotate (joy1x,joy1y)
    v = @view-@pos # view vector
    v.rotate(x/1000,y/1000,0)
    @view = @pos+v
    
    # translate (joy2y)
    v = @view-@pos # view vector
    @pos  = @pos+v*(z/100)
    @view = @view+v*(z/100)
  end
  
end
