require 'vector'

class Camera
  
  attr_accessor :pos, :view, :rot
  
  def initialize
    @pos  = MVector.new(0,10,100) # {:x=>0,:y=>10, :z=>100}
    @view = MVector.new(0,0,0) # {:x=>0,:y=>0, :z=>0}
    @rot  = MVector.new(0,1,0) # {:x=>0,:y=>1, :z=>0}
  end
  
  
  # the cam moves forward (following its view) with the z parameter
  # the view is moved with parameters x and y  
  def move(x,y,z)
    # rotate (x,y)/z
    v = @view-@pos # view vector
    puts "  #{v}" if CONFIG[:log][:camera]
    v.rotate(x,y,0)
    puts "=>#{v}" if CONFIG[:log][:camera]
    @view = @pos+v
    # translate (z)
    
    #@camxa += @joy1x / 100.0
    #@camya += @joy1y / 100.0
    #@camz  += @joy1z / 100.0
    
    #pos.x += x / 100.0
    #pos.y += y / 100.0
    #pos.z += z / 100.0
  end
  
end
