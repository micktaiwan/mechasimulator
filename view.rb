require 'model'
require 'rubygems'
require 'rubygame'
require 'opengl'

class MechaSimView
  
  def initialize(model)
    @model = model
    @screen = screen_make(640,480)
    @queue = Rubygame::EventQueue.new()
    set_gl
  end
  
  def update
    
    @queue.each { |event|
      puts "Event: #{event}, #{event.class.name}"  if CONFIG[:log][:event]
      @@running = nil if event.class.name == "Rubygame::QuitEvent"
    }
    
    GL::Clear(GL::COLOR_BUFFER_BIT)
    #puts @model.space.inspect
    @model.space.each { |geom|
      draw_geom(geom) 
    }
    Rubygame::GL.swap_buffers()
  end
  
  private
  
  def draw_geom(geom)
    puts geom.position.to_s  if CONFIG[:log][:pos]
    #draw_box(geom.position.x+320,geom.position.y+240, 10)
    draw_box(geom)
  end
  
  def draw_box(geom)
    x = geom.position.x + 320
    y = geom.position.y + 240
    z = geom.position.z
    lx = geom.lx
    ly = geom.ly
    lz = geom.lz
    
    GL::Begin(GL::QUADS)
    # face
    GL::Vertex(x, y)
    GL::Vertex(x+lx, y)
    GL::Vertex(x+lx, y+ly)
    GL::Vertex(x, y+ly)
    GL::End()
  end

  def draw_simple_box(x,y,w)
    GL::Begin(GL::QUADS)
    GL::Vertex(x, w)
    GL::Vertex(x, y+w)
    GL::Vertex(x+w, y+w)
    GL::Vertex(x+w, y)
    GL::End()
  end
  
  def screen_make(wide, high, fullscreen = false, doublebuf = true) 
    flags  = Rubygame::HWSURFACE | Rubygame::ANYFORMAT | Rubygame::OPENGL
    flags |= Rubygame::FULLSCREEN if fullscreen
    flags |= Rubygame::DOUBLEBUF  if doublebuf
    screen = Rubygame::Screen.new( [wide, high], 16, flags )
    screen.title = 'Robot Simulator'
    screen
  end 
  
  def set_gl
    Rubygame::GL.set_attrib(Rubygame::GL::RED_SIZE, 5)
    Rubygame::GL.set_attrib(Rubygame::GL::GREEN_SIZE, 5)
    Rubygame::GL.set_attrib(Rubygame::GL::BLUE_SIZE, 5)
    Rubygame::GL.set_attrib(Rubygame::GL::DEPTH_SIZE, 16)
    Rubygame::GL.set_attrib(Rubygame::GL::DOUBLEBUFFER, 1)
    GL::ClearColor(0,0,0,0)
    GL::Clear(GL::COLOR_BUFFER_BIT)
    GL::Color(1,1,1)
    GL::Ortho(0,640,480,0,-1,1)
    #GL::Enable( GL::TEXTURE_2D );
  end
  
end
