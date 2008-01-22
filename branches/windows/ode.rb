module ODE
  
  class Position
    
    def initialize(a=nil)
      @p = a and return if a
      @p = [0,0,0]
    end
    
    def x; @p[0]; end
    def x=(i); @p[0]=i; end
    def y; @p[1]; end
    def y=(i); @p[1]=i; end
    def z; @p[2]; end
    def z=(i); @p[2]=i; end
    
  end
  
  class Geometry
    attr_accessor :position
    
    def initialize
      @position = Position.new
      @rotation = Position.new
    end
    
  end
  
  class Box < Geometry
    attr_accessor :body, :position, :rotation, :lx, :ly, :lz
    def initialize(lx,ly,lz,space)
      super()
      @lx, @ly, @lz = lx,ly,lz
      space.add_geom(self) if space
    end
  end
  
  
  class Body
    
    attr_accessor :position
    
    def addForce(f)
      puts 'addForce'
    end
    
    
  end
  
  class World
    
    attr_accessor :gravity
    
    def createBody
      Body.new
    end
    
    def step(s)
      puts 'step'
    end
  end
  
  class Space
    def initialize
      @geoms = []
    end
    
    def each
      @geoms.each {|g| yield g}
    end
    
    def add_geom(geom)
      @geoms << geom if not @geoms.include?(geom)
    end
  end
  
  class JointGroup
    def initialize(joint_type, world)
      
    end
    
    def empty
      
    end
  end
  
  class Joint
    
  end
  
  class ContactJoint < Joint
    
  end
  
end