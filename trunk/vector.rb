
class MVector
  
  attr_accessor :x,:y,:z
  
  def initialize(x=0,y=0,z=0)
    @x,@y,@z = x,y,z
  end
  
  def to_s
    "|%s|" % [@x,@y,@z].join(',')
  end
  def -(v)
    MVector.new(@x-v.x,@y-v.y,@z-v.z)
  end
  
  def +(v)
    MVector.new(@x+v.x,@y+v.y,@z+v.z)
  end
  
  def rotate(a,b,c)
    @x = @x*Math.cos(a/1000)-@y*Math.sin(a/1000)
    @y = @y*Math.cos(a/1000)-@x*Math.sin(a/1000)
    
    @x = @x*Math.cos(b/1000)-@z*Math.sin(b/1000)
    @z = @z*Math.cos(b/1000)-@x*Math.sin(b/1000)
    
    @y = @y*Math.cos(c/1000)-@z*Math.sin(c/1000)
    @z = @z*Math.cos(c/1000)-@y*Math.sin(c/1000)
  end
  
end
