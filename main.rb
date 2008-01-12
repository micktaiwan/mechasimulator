require 'view'
require 'model'
require 'controller'

class RobotSim
  
  def initialize
    @m = RobotSimModel.new
    @v = RobotSimView.new(@m)
    @c = RobotSimController.new(@m,@v)
  end
  
  def loop
    while @@running do
      @c.update
      @m.update
      @v.update
      sleep CONFIG[:sleep]
    end
    #puts 'begin loop'
    #view_thread  = Thread.new do @v.update end
    #model_thread = Thread.new do @m.update end
    #controller_thread = Thread.new do @c.process_inputs end
    #view_thread.join
    #model_thread.join
    #controller_thread.join
    #puts 'end loop'
  end
  
end

Rubygame.init()
begin
  @@running = true
  RobotSim.new.loop
rescue Exception => e
  @@running = nil
  puts "Error: " + e.message
  raise
end
puts 'end'
Rubygame.quit()
