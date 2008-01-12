require 'rubygems'
require 'joystick'
require 'config'

# takes inputs and update view and model
class RobotSimController
  
  def initialize(model,view)
    @model, @view = model, view
    @joy = Joystick::Device.new CONFIG[:joy][:dev]
    #TODO catch errors
  end
  
  def update
    process_inputs
  end
  
  def process_inputs
    process_joy  
  end
  
  def process_joy
    return if not @joy.pending?
    ev = @joy.ev
    case ev.type
    when Joystick::Event::INIT
      puts 'init'
    when Joystick::Event::BUTTON
      puts "button: #{ev.num}, #{ev.val}"
    when Joystick::Event::AXIS
      #puts "axis: #{ev.num}, #{ev.val}"
      case ev.num
      when CONFIG[:joy][:axe1x]
        @model.joy1x = ev.val / 32000.0
        puts "x=#{@model.joy1x}"
      when CONFIG[:joy][:axe1y]
        @model.joy1y = ev.val / 32000.0
        puts "y=#{@model.joy1y}"
      when CONFIG[:joy][:axe2x] 
        #@model.joy2y = ev.val / 100
      when CONFIG[:joy][:axe2y]
        #@model.joy2x = ev.val / 100
      end
    else
      puts "? #{ev.type}"
    end    
  end
  
end
