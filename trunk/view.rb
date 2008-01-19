require 'model'
require 'opengl'
require 'util'

class MechaSimView
  
  def initialize(model)
    @model = model
    @screen = screen_make(640,480)
    set_gl
  end
  
  def update
    
    # camera
    GL::Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
    GL::LoadIdentity()
    GLU::LookAt(@model.cam.pos.x, @model.cam.pos.y, @model.cam.pos.z,
                @model.cam.view.x,@model.cam.view.y,@model.cam.view.z,
                @model.cam.rot.x, @model.cam.rot.y, @model.cam.rot.z)
    
    # draw geometries
    @model.space.each { |geom|
      draw_geom(geom)
    }
    
    #draw_test
    draw_grid
    draw_axes
    
    # swap buffers
    Rubygame::GL.swap_buffers()
    
  end
  
  private
  
  def draw_geom(geom)
    puts geom.position.to_s  if CONFIG[:log][:pos]
    #draw_box(geom.position.x+320,geom.position.y+240, 10)
    draw_box(geom)
  end
  
  def draw_test
    x = 100.0
    GL::Color(1,1,1)
    GL::Begin(GL::LINES)
    100.times {
      GL::Vertex3d(rand(x)-x/2,rand(x)-x/2,rand(x)-x/2)
      GL::Vertex3d(rand(x)-x/2,rand(x)-x/2,rand(x)-x/2)
    }
    GL::End()
  end
  
  def draw_box(geom)
    @lx = geom.lx
    @ly = geom.ly
    @lz = geom.lz
    x = geom.position.x#-lx/2
    y = geom.position.y#-ly/2
    z = geom.position.z#-lz/2
    r = geom.rotation
    rx = r.roll.to_deg
    ry = -r.pitch.to_deg
    rz = r.yaw.to_deg
    #rx = r[0].to_deg
    #ry = r[1].to_deg
    #rz = r[2].to_deg
    
    #puts "#{x},#{y},#{z}"
    #puts "#{r.pitch.to_deg},#{r.roll.to_deg},#{r.yaw.to_deg}"
    
    GL::PushMatrix()
    
    # rotate
    GL::Translate(x,y,z)
    GL::Rotate(rx,  1,0,0)
    GL::Rotate(ry,0,1,0)
    GL::Rotate(rz,   0,0,1)

    # draw
    GL::Begin(GL::QUADS)
    # bottom
    GL::Color(0,0,1)
    v(0,0,0)
    v(@lx, 0,0)
    v(@lx, @ly,0)
    v(0, @ly,0)
    # up
    GL::Color(0,1,0)
    v(0,0,@lz)
    v(@lx, 0,@lz)
    v(@lx, @ly,@lz)
    v(0, @ly,@lz)
    # back
    GL::Color(0,1,1)
    v(0,0,0)
    v(0,0,@lz)
    v(@lx,0,@lz)
    v(@lx,0,0)
    #front
    GL::Color(1,0,0)
    v(0,@ly,0)
    v(@lx,@ly,0)
    v(@lx,@ly,@lz)
    v(0,@ly,@lz)
    #left
    GL::Color(1,0,1)
    v(0,0,0)
    v(0,@ly,0)
    v(0,@ly,@lz)
    v(0,0,@lz)
    #right
    GL::Color(1,1,0)
    v(@lx,0,0)
    v(@lx,@ly,0)
    v(@lx,@ly,@lz)
    v(@lx,0,@lz)    
    GL::End()
    
    GL::PopMatrix()
  end
  
  def v(x,y,z)
    GL::Vertex3d(x-@lx/2,y-@ly/2,z-@lz/2)
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
    
    
    # Initialize
    GL::ClearColor(0.0,0.0,0.0,0)
    GL::Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
    GL::Enable(GL::DEPTH_TEST)
    GL::Disable(GL::LIGHTING)
    #GL::Enable(GL::LIGHTING)
    #GL::Enable(GL::NORMALIZE)
    #GL::ShadeModel(GL::FLAT)
    
    # Projection
    GL::MatrixMode(GL::PROJECTION)
    GL::LoadIdentity()
    
    # Viewport
    GL::Viewport(0,0,640,480)
    GLU::Perspective(45.0, 1.333, 1, 100.0)
    #GL::Ortho(-100,100,-100,100,-100,100)
    # Initialize ModelView matrix
    GL::MatrixMode(GL::MODELVIEW)
    
    # Light source
    GL::Lightfv(GL::LIGHT0,GL::POSITION,[0,0,6,0])
    GL::Lightfv(GL::LIGHT0,GL::DIFFUSE,[1,1,1,1])
    GL::Lightfv(GL::LIGHT0,GL::SPECULAR,[1,1,1,1])
    GL::Enable(GL::LIGHT0)
  end
  
  def draw_axes
    GL::PushMatrix()
    GL::Begin(GL::LINES)
    
    # x axis
    GL::Color(1,0,0)
    GL::Vertex3d(0,0,0)
    GL::Vertex3d(1,0,0)
    # y axis
    GL::Color(0,1,0)
    GL::Vertex3d(0,0,0)
    GL::Vertex3d(0,1,0)
    # z axis
    GL::Color(0,0,1)
    GL::Vertex3d(0,0,0)
    GL::Vertex3d(0,0,1)
    
    GL::End()
    GL::PopMatrix()
  end
  
  def draw_grid
    GL::PushMatrix()
    GL::Begin(GL::LINES)
    
    GL::Color(0.3,0.3,0.3)
    
    x = 20
    x.times{ |i|
      GL::Vertex3d(i-x/2,-x/2,0)
      GL::Vertex3d(i-x/2,x/2,0)
      GL::Vertex3d(-x/2,i-x/2,0)
      GL::Vertex3d(x/2,i-x/2,0)
    }
    
    GL::End()
    GL::PopMatrix()
  end
end
