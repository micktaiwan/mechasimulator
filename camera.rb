require 'vector'

class Camera
  
  attr_accessor :pos, :view, :rot
  
  def initialize
    @pos  = MVector.new(1,-4,2)
    @rot  = MVector.new(-80,0,-10)
    @follow_obj = nil
  end
  
  # rotx, roty: rotation along x and y
  # forward: move along the direction of the view
  def move(forward,rotx,rotz)
    
    return if not (forward!=0 or rotx!=0 or rotz!=0)
    
    if CONFIG[:log][:camera]
      puts "move: forward=#{forward} rotx=#{rotx} rotz=#{rotz}"
      puts "cam: pos=#{@pos} rot=#{@rot}" 
    end

    #@pos  = @pos+@view.normalize if forward != 0
    @rot.x -= rotx
    @rot.z -= rotz

  end
  
  # give a object and a method to to call to get a MVector (a point) to follow
  def set_follow(obj,method)
    @follow_obj     = obj
    @follow_method  = method
  end
  
  def follow
    return if not @follow_obj
    point = @follow_obj.send(@follow_method)
    x = @pos.x - point.x
    y = @pos.y - point.y
    #z = @pos.z - point.z
    scale = 45/Math.atan(1) 
    rotz = (scale*Math.atan2(y,x))+90
    @rot.z = rotz
  end
  
end
