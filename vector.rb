
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
  
  def *( scalar )
    scalar = Float(scalar)
    MVector.new(@x*scalar,@y*scalar,@z*scalar)
  end
  
  def rotate(a,b,c)
    #@x = @x*Math.cos(a)-@y*Math.sin(a)
    #@y = @y*Math.cos(a)-@x*Math.sin(a)
    
    @x = @x*Math.cos(-a)-@z*Math.sin(-a)
    @z = @z*Math.cos(-a)-@x*Math.sin(-a)
    
    @y = @y*Math.cos(-b)-@z*Math.sin(-b)
    @z = @z*Math.cos(-b)-@y*Math.sin(-b)
  end
  
  ### Normalizes the vector in place.
  def normalize!
    mag = self.mag
    @elements = @elements.collect {|elem| elem / mag }
    return self
  end
  
end
