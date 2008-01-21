require 'vector'

class Camera
  
  attr_accessor :pos, :view, :rot
  
  def initialize
    @pos  = MVector.new(-1,-5,20)
    @view = MVector.new(0,0,0)
    @rot  = MVector.new(0,0,1)
    #@pos  = MVector.new(-5,-5,5)
    #@view = MVector.new(-4.4,-4.3,4.4)
    #@rot  = MVector.new(0,0,1)
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
    # @pos.x += x1/100
    # @pos.y -= y1/100
    # @pos.z -= y2/100
    # translate (joy2y)
    #v = (@view-@pos)#.normalize! # view vector
    #@pos  = @pos+v*(y2/100)
    #@view = @view+v*(y2/100)
    
    # rotate (joy1x)
    
    v = (@view-@pos) #.normalize! # view vector
    angle = Math::asin(v.y)
    angle -= x1/100
    v.x = Math::cos(angle)
    v.y = Math::sin(angle)
    @view = @pos+v
    
    if CONFIG[:log][:camera]
      puts "vx=#{v.x} vy=#{v.y} vz=#{v.z} tan=#{v.y/v.x} "
      puts "angle=#{angle.to_deg}" 
      puts "---" 
    end
    
    # up / down without the view
    @pos.z -= y1/100
    
    # up / down with the view
    @pos.z -= x2/100
    @view.z-= x2/100
    
    #translate (joy2y)
    v = (@view-@pos)*(y2/100) #.normalize!
    @pos  = @pos+v
    @view = @pos+v
    
  end
  
end
