require 'worldobject'
require 'camera'
STEP = 0.05

class MechaSimModel
  
  attr_accessor :joy1x, :joy1y, :joy2x, :joy2y
  attr_accessor :robot, :space, :cam
  
  def initialize
    @joy1x, @joy1y, @joy2x, @joy2y = 0,0,0,0
    @world = ODE::World.new
    @world.gravity = [0,0,-1]
    @world.erp = 0.8
    @world.cfm = 0.00001

    @space = ODE::Space.new
    @joints = ODE::JointGroup.new(ODE::ContactJoint,@world)
    
    #robot
    @robot = WorldObject.new(@world,@space)
    #@robot.body.position = [0,0,3]
    #20.times { |i|
    #  o = WorldObject.new(@world,@space)
    #  o.body.position = [rand(8.0)-4,rand(8.0)-4,3+rand(2)]
    #}
    
    # ground
    #body = @world.createBody
    geom = ODE::Geometry::Box.new(1.0,1.0,0.1,@space)
    #geom.body = body
    geom.position = [0,0,-0.1]
    
    @cam = Camera.new
  end
  
  def update
    
    case CONFIG[:joy][:control]
    when 'robot'
      # apply forces
      @robot.body.addForce([@joy1x,-@joy1y,@joy2y])
    when 'camera'    
      @cam.move(@joy1x, @joy1y, @joy2x, @joy2y)
    end
    # collision    
    c = []
    @space.each { |g1|
      #break
      @space.each { |g2|
        g1.collideWith(g2) { |contact|
          puts "already: #{contact}" and next if c.include?(contact)
          puts contact.to_s if CONFIG[:log][:collision]
          contact.surface.bounce = 0.2
          contact.surface.mu = 5000
          j = @joints.createJoint(contact)
          j.attach(g1.body, g2.body)
          c << contact
        }
      }
    }
    # step
    @world.step(STEP)  
    
    # remove all contact joints
    @joints.empty
  end
  
end
