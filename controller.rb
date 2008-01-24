#require 'rubygems'
require 'rubygame'
require 'joystick'
require 'config'

# takes inputs and update view and model
class MechaSimController
  
  def initialize(model,view)
    @model, @view = model, view
    @events = Rubygame::EventQueue.new
    begin
      @joy = Joystick::Device.new CONFIG[:joy][:dev]
    rescue Exception => e
      puts "*** Can not find the joystick '#{CONFIG[:joy][:dev]}'\n    (#{e.message})\n    Please edit your configuration file config.rb"
      @joy = nil
    end
  end
  
  def update
    process_inputs
  end
  
  
  def process_inputs
    
    # rubygame events
    @events.each { |event|
      puts "Event: #{event}, #{event.class.name}"  if CONFIG[:log][:event]
      case event
        
        when Rubygame::QuitEvent
        @@running = nil
        
        when Rubygame::KeyDownEvent
        @@running = nil if event.key == Rubygame::K_ESCAPE

        #Indicates that the mouse cursor moved.
        #This event has these attributes:
        #pos:  the new position of the cursor, in the form [x,y].
        #rel:  the relative movement of the cursor since the last update, [x,y].
        #buttons:  the mouse buttons that were being held during the movement, an Array of zero or more of these constants in module Rubygame (or the corresponding button number):
        #MOUSE_LEFT: 1; left mouse button
        #MOUSE_MIDDLE: 2; middle mouse button
        #MOUSE_RIGHT:  3; right mouse button
      when Rubygame::MouseMotionEvent
        puts "Pos: #{event.pos.join(',')}, relative: #{event.rel.join(',')}, bouttons: #{event.buttons}"
        @model.cam.pos.x = event.pos.x/10
      end
    }
    
    # joy
    process_joy  
    
  end
  
  def process_joy
    return if !@joy or !@joy.pending?
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
