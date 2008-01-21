class MVector
  
  attr_accessor :x,:y,:z
  
  def initialize(x,y,z)
    @x,@y,@z = x,y,z
  end
  
  def to_s
    "|%s|" % [@x,@y,@z].join(', ')
  end
  
  def -(v)
    MVector.new(@x-v.x,@y-v.y,@z-v.z)
  end
  
  def +(v)
    MVector.new(@x+v.x,@y+v.y,@z+v.z)
  end
  
  def *( scalar )
    MVector.new(@x*scalar,@y*scalar,@z*scalar)
  end
  
  def /( scalar )
    MVector.new(@x/scalar,@y/scalar,@z/scalar)
  end
  
  
  def rotate!(a,b,c)
    #@x = @x*Math.cos(a)-@y*Math.sin(a)
    #@y = @y*Math.cos(a)-@x*Math.sin(a)
    
    @x = @x*Math.cos(-a)-@z*Math.sin(-a)
    @z = @z*Math.cos(-a)-@x*Math.sin(-a)
    
    @y = @y*Math.cos(-b)-@z*Math.sin(-b)
    @z = @z*Math.cos(-b)-@y*Math.sin(-b)
  end
  
  ### Normalizes the vector in place.
  def normalize!
    @x /= length
    @y /= length
    @z /= length
    self
  end
  
  ### Returns the magnitude of the vector, measured in the Euclidean norm.
  def length
    Math.sqrt( self.sqr )
  end
  
  
  ### Returns the dot product of the vector with itself, which is also the
  ### squared length of the vector, as measured in the Euclidean norm.
  def sqr
    self.dot( self )
  end
  
  ### Return the dot-product
  def dot(v)
    scalar = 0.0
    scalar += @x*v.x
    scalar += @y*v.y
    scalar += @z*v.z
    return scalar
  end
  
end
