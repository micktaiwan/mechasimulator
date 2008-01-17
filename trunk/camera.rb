require 'vector'

class Camera
  
  attr_accessor :pos, :view, :rot
  
  def initialize
    @pos  = MVector.new(0,10,100)
    @view = MVector.new(0,0,0)
    @rot  = MVector.new(0,1,0)
  end
  
  
  # the cam moves forward (following its view) with the z parameter
  # the view is moved with parameters x and y  
  def move(x,y,z)
    # rotate (joy1x,joy1y)
    v = @view-@pos # view vector
    #puts "  #{v}" if CONFIG[:log][:camera]
    v.rotate(x/1000,y/1000,0)
    #puts "=>#{v}" if CONFIG[:log][:camera]
    @view = @pos+v

    # translate (joy2y)
    v = @view-@pos # view vector
    @pos = @pos+v*(z/100)
  end
  
end
