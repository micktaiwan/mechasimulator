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
