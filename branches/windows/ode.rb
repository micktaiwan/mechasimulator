module ODE
  
  #  class Position
  #    
  #    def initialize(a=nil)
  #      @p = a and return if a
  #      @p = [0,0,0]
  #    end
  #    
  #    def x; @p[0]; end
  #    def x=(i); @p[0]=i; end
  #    def y; @p[1]; end
  #    def y=(i); @p[1]=i; end
  #    def z; @p[2]; end
  #    def z=(i); @p[2]=i; end
  #    
  #  end
  
  class Geometry
    attr_accessor :position
    
    def initialize
      @position = MVector.new
      @rotation = MVector.new
      @forces = []
    end
    
    def position=(arr)
      @position.x, @position.y, @position.z = arr[0],arr[1],arr[2]
    end
    
    def add_force(f)
      @forces << MVector.new(f)
    end
    
    def apply_forces
      @forces.each { |f|
        @position = @position + f 
      }
      @forces = []  
    end
    
  end
  
  class Box < Geometry
    attr_accessor :position, :rotation, :lx, :ly, :lz
    def initialize(lx,ly,lz,space)
      super()
      @lx, @ly, @lz = lx,ly,lz
      space.add_geom(self) if space
    end
  end
  
  
  #  class Body
  #    
  #    attr_accessor :geom
  #    
  #    def addForce(f)
  #      puts 'addForce'
  #      
  #      
  #    end
  #    
  #    def position
  #      @geom.position
  #    end
  #    
  #    def position=(p)
  #      @geom.position = p
  #    end
  #    
  #  end
  
  class World
    
    attr_accessor :gravity
    
    def initialize
      @spaces = []
    end
    
    def add_space
      s = Space.new
      @spaces << s if not @spaces.include?(s)
      s
    end
    
    #    def createBody
    #      Body.new
    #    end
    
    def step(st)
      puts 'step'
      @spaces.each {|s| s.step(st)}
    end
    
  end
  
  class Space
    
    def initialize
      @geoms = []
    end
    
    def each_geom
      @geoms.each {|g| yield g}
    end
    
    def add_geom(geom)
      @geoms << geom if not @geoms.include?(geom)
    end
    
    def step(st)
      # apply forces
      @geoms.each {|g| 
        g.apply_forces
      }
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