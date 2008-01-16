require 'worldobject'
require 'camera'
STEP = 0.05

class MechaSimModel
  
  attr_accessor :joy1x, :joy1y, :joy2x, :joy2y
  attr_accessor :robot, :space, :cam
  
  def initialize
    @joy1x, @joy1y, @joy2x, @joy2y = 0,0,0,0
    @world = ODE::World.new
    #@world.gravity = [0,9.81,0]
    @space = ODE::Space.new
    @joints = ODE::JointGroup.new(ODE::ContactJoint,@world)
    
    #robot
    @robot = WorldObject.new(@world,@space)
    
    # ground
    #body = @world.createBody
    geom = ODE::Geometry::Box.new(1000,10,1000,@space)
    #geom.body = body
    geom.position = [-500,-10,-500]
    
    @cam = Camera.new
  end
  
  def update
    # apply forces
    #@robot.body.addForce([@joy1x,-@joy1y,@joy2y])
    @cam.pos[:x] += @joy1x /100.0
    @cam.pos[:y] += @joy1y /100.0
    @cam.pos[:z] += @joy2y /100.0
    
    
    # collision    
    @space.each { |g1|
      @space.each { |g2|
        g1.collideWith(g2) { |contact|
        puts contact.to_s if CONFIG[:log][:collision]
        contact.surface.bounce = 0.2
        contact.surface.mu = 5000
        j = @joints.createJoint(contact)
        j.attach(g1.body, g2.body)
        }
      }
    }
    
    # step
    @world.step(STEP)  
    
    # remove all contact joints
    @joints.empty
  end
  
end
