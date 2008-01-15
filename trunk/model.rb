require 'worldobject'
STEP = 0.2

class MechaSimModel
  
  attr_accessor :joy1x, :joy1y, :joy2x, :joy2y
  attr_accessor :robot, :space
  
  def initialize
    @joy1x, @joy1y, @joy2x, @joy2y = 0,0,0,0
    @world = ODE::World.new
    #@world.gravity = [0,9.81,0]
    @space = ODE::Space.new
    @joints = ODE::JointGroup.new(ODE::ContactJoint,@world)
    
    #robot
    @robot = WorldObject.new(@world,@space)
    
    # ground
    body = @world.createBody
    geom = ODE::Geometry::Box.new(100,1,100,@space)
    geom.body = body
    body.position = [-50,1,-50]
  end
  
  def update
    # apply forces
    @robot.body.addForce([@joy1x,@joy1y,0])
    
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