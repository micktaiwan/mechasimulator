require 'rubygems'
require 'rubygame'
require 'view'
require 'model'
require 'controller'

class MechaSim
  
  def initialize
    @m = MechaSimModel.new
    @v = MechaSimView.new(@m)
    @c = MechaSimController.new(@m,@v)
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
  MechaSim.new.loop
rescue Exception => e
  @@running = nil
  puts "Error: " + e.message
  raise
end
puts 'end'
Rubygame.quit()
