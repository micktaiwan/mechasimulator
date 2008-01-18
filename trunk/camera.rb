require 'vector'

class Camera
  
  attr_accessor :pos, :view, :rot
  
  def initialize
    @pos  = MVector.new(10.0,10.0,10.0)
    @view = MVector.new(0.0,0.0,1.0)
    @rot  = MVector.new(0.0,0.0,1.0)
  end
  
  
  # the cam moves forward (following its view) with the y2 parameter
  # the view is moved with parameters x1 and y1
  # the rotation along the view is done with x2 
  def move(x1,y1,x2,y2)
    
    return if not (x1!=0 or y1!=0 or x2!=0 or y2!=0)
    
    if CONFIG[:log][:camera]
      puts "move: x1=#{x1} y1=#{y1} x1=#{x1} x2=#{x2}"
      puts "cam: pos=#{pos} view=#{view} rot=#{rot}" 
    end
    
    # rotate (joy1x,joy1y)
    #v = (@view-@pos).normalize! # view vector
    #v.rotate!(x1/1000,y1/1000,0)
    #@view = @pos+v
    
    # translate (joy2y)
    v = (@view-@pos)#.normalize! # view vector
    @pos  = @pos+v*(y2/100)
    @view = @view+v*(y2/100)
  end
  
end
