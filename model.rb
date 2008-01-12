require 'worldobject'

class RobotSimModel
  
  attr_accessor :joy1x, :joy1y, :joy2x, :joy2y
  attr_accessor :robot
  
  def initialize
    @joy1x, @joy1y, @joy2x, @joy2y = 0,0,0,0
    @objects = []
    @robot = WorldObject.new
    @speed = [0.0,0.0]
  end
  
  def update
    @speed[0] += @joy1x
    @speed[1] += @joy1y
    #puts @speed[0]
    @speed[0] *= 0.99
    @speed[1] *= 0.99
    @speed[1] += 0.5
    #puts @speed[0]
    @speed[0] = -@speed[0] and @robot.x = 0 if @robot.x < 0
    @speed[0] = -@speed[0] and @robot.x = 630 if @robot.x > 630
    #@speed[1] = -@speed[1] and @robot.y = 0 if @robot.y < 0
    @speed[1] = -@speed[1]*0.75 and @robot.y = 470 if @robot.y > 470
    @robot.x += @speed[0]
    @robot.y += @speed[1]
  end
  
end
