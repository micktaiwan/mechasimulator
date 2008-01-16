require 'rubygems'
require 'joystick'
require 'config'

# takes inputs and update view and model
class MechaSimController
  
  def initialize(model,view)
    @model, @view = model, view
    begin
      @joy = Joystick::Device.new CONFIG[:joy][:dev]
    rescue Exception => e
      puts "*** Can not find the joystick '#{CONFIG[:joy][:dev]}'\n    (#{e.message})\n    Please edit your configuration file config.rb"
      exit 1
    end
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
      puts 'init' if CONFIG[:log][:joy]
    when Joystick::Event::BUTTON
      puts "button: #{ev.num}, #{ev.val}" if CONFIG[:log][:joy]
    when Joystick::Event::AXIS
      puts "axis: #{ev.num}, #{ev.val}" if CONFIG[:log][:joy]
      case ev.num
      when CONFIG[:joy][:axe1x]
        @model.joy1x = ev.val / CONFIG[:joy][:factor]
        puts "x=#{@model.joy1x}"  if CONFIG[:log][:joy]
      when CONFIG[:joy][:axe1y]
        @model.joy1y = ev.val / CONFIG[:joy][:factor]
        puts "y=#{@model.joy1y}" if CONFIG[:log][:joy]
      when CONFIG[:joy][:axe2x] 
        @model.joy2x = ev.val / CONFIG[:joy][:factor]
      when CONFIG[:joy][:axe2y]
        @model.joy2y = ev.val  / CONFIG[:joy][:factor]
      end
    else
      puts "Unknown type #{ev.type}" if CONFIG[:log][:joy]
    end    
  end
  
end
