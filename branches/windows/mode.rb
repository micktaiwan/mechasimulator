# mode: Mick ODE.....

class Array
  
  def x; self[0]; end
  def y; self[1]; end
  def z; self[2]; end
  
end

module ODE
  
  class Geometry
    
    def initialize
      @position = MVector.new
      @rotation = MVector.new
      @forces = []
    end
    
    def position=(arr)
      @position.from_a(arr)
    end
    
    def add_force(f)
      #puts "Add_force: #{f.join(',')}"
      @forces << MVector.new(f)
    end
    
    def apply_forces
      @forces.each { |f|
        #puts "Applying force: #{f}"
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
      puts 'step' if CONFIG[:log][:debug]
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