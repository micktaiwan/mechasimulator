require 'ode'
require 'worldobject'
require 'camera'
STEP = 0.005

class MechaSimModel
  
  attr_accessor :joy1x, :joy1y, :joy2x, :joy2y
  attr_accessor :robot, :space, :cam
  
  def initialize
    @joy1x, @joy1y, @joy2x, @joy2y = 0,0,0,0
    @world = ODE::World.new
    #@world.gravity = [0,0,-10]
    #@world.erp = 0.8
    #@world.cfm = 0.00001
    
    @space = ODE::Space.new
    @joints = ODE::JointGroup.new(ODE::ContactJoint,@world)
    
    #robot
    @robot = ODE::Box.new(1,1,1,@space)
#    @robot.body.position = [0,0,2]
    
    # second body for joint test
    
    #body = @world.createBody
    #body.position = [0,0,0]
    #geom = ODE::Geometry::Box.new(3,1,1,@space)
    #geom.body = body
    
    #body = @world.createBody
    #body.position = [0,0,10]
    #geom = ODE::Geometry::Box.new(1,1,1,@space)
    #geom.body = body
    
    
    #body.rotation = [0,0,45.to_rad,45.to_rad]
    #@robot_joints = ODE::JointGroup.new(ODE::HingeJoint,@world)
    #j = ODE::HingeJoint.new(@world,@robot_joints)
    #j.anchor = [0,0,1]
    #j.axis   = [0,1,0]
    #j.attach(body,@robot.body)
    
    
    #40.times { |i|
    #  o = ODE::Geometry::Box.new(1,1,1,@space)
    #  o.position = [rand(16)-8,rand(16)-8,rand(16)-8]
    #}
    
    # ground
    #body = @world.createBody
    geom = ODE::Box.new(20.0,20.0,0.1,@space)
    #geom.body = body
    geom.position = ODE::Position.new([0,0,-0.1])
    #geom.rotation = [45,0,0,0]
    
    @cam = Camera.new
  end
  
  def update
    
    # apply forces
    case CONFIG[:joy][:control]
    when 'robot'
      @robot.add_force([@joy1x,-@joy1y,-@joy2y])
    when 'camera'    
      @cam.move(@joy1x, @joy1y, @joy2x, @joy2y)
    end
    # collision    
    c = []
#    @space.each { |g1|
#      #break
#      @space.each { |g2|
#        g1.collideWith(g2) { |contact|
#          puts "already: #{contact}" and next if c.include?(contact)
#          puts contact.to_s if CONFIG[:log][:collision]
#          contact.surface.bounce = 0.2
#          contact.surface.mu = 5000
#          j = @joints.createJoint(contact)
#          j.attach(g1.body, g2.body)
#          c << contact
#        }
#      }
#    }
    # step
    @world.step(STEP)  
    
    # remove all contact joints
    @joints.empty
  end
  
end
