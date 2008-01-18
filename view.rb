require 'model'
require 'opengl'

class MechaSimView
  
  def initialize(model)
    @model = model
    @screen = screen_make(640,480)
    set_gl
  end
  
  def update
    
    # camera
    GL::Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
    GL::LoadIdentity();
    GLU::LookAt(@model.cam.pos.x, @model.cam.pos.y, @model.cam.pos.z,
                @model.cam.view.x,@model.cam.view.y,@model.cam.view.z,
                @model.cam.rot.x, @model.cam.rot.y, @model.cam.rot.z)
    
    # draw geometries
    @model.space.each { |geom|
      draw_geom(geom) 
    }
    
    #draw_test
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
    x = geom.position.x #+ 320
    y = geom.position.y #+ 240
    z = geom.position.z
    lx = geom.lx
    ly = geom.ly
    lz = geom.lz
    
    GL::PushMatrix()
    
    GL::Begin(GL::QUADS)
    # back
    GL::Color(0,0,1)
    GL::Vertex3d(x,y,z)
    GL::Vertex3d(x+lx, y,z)
    GL::Vertex3d(x+lx, y+ly,z)
    GL::Vertex3d(x, y+ly,z)
    # front
    GL::Color(0,1,0)
    GL::Vertex3d(x,y,z+lz)
    GL::Vertex3d(x+lx, y,z+lz)
    GL::Vertex3d(x+lx, y+ly,z+lz)
    GL::Vertex3d(x, y+ly,z+lz)
    # down
    GL::Color(0,1,1)
    GL::Vertex3d(x,y,z)
    GL::Vertex3d(x,y,z+lz)
    GL::Vertex3d(x+lx,y,z+lz)
    GL::Vertex3d(x+lx,y,z)
    #up
    GL::Color(1,0,0)
    GL::Vertex3d(x,y+ly,z)
    GL::Vertex3d(x+lx,y+ly,z)
    GL::Vertex3d(x+lx,y+ly,z+lz)
    GL::Vertex3d(x,y+ly,z+lz)
    #left
    GL::Color(1,0,1)
    GL::Vertex3d(x,y,z)
    GL::Vertex3d(x,y+ly,z)
    GL::Vertex3d(x,y+ly,z+lz)
    GL::Vertex3d(x,y,z+lz)
    #right
    GL::Color(1,1,0)
    GL::Vertex3d(x+lx,y,z)
    GL::Vertex3d(x+lx,y+ly,z)
    GL::Vertex3d(x+lx,y+ly,z+lz)
    GL::Vertex3d(x+lx,y,z+lz)    
    GL::End()
    
    GL::PopMatrix()
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
    
    # Viewport
    GL::Viewport(0,0,640,480)
    
    # Initialize
    GL::ClearColor(0.0,0.0,0.0,0)
    GL::Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT);
    GL::Enable(GL::DEPTH_TEST)
    GL::Disable(GL::LIGHTING)
    #GL::Enable(GL::LIGHTING)
    GL::Enable(GL::NORMALIZE)
    GL::ShadeModel(GL::FLAT)
    
    # Projection
    GL::MatrixMode(GL::PROJECTION)
    GL::LoadIdentity()
    GLU::Perspective(45.0,1.333 , 0.0001, 1000.0);
    GL::Ortho(-100,100,-100,100,-100,100)
    
    # Initialize ModelView matrix
    GL::MatrixMode(GL::MODELVIEW)
    GL::LoadIdentity()
    
    # Light source
    GL::Lightfv(GL::LIGHT0,GL::POSITION,[0,0,1,0])
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
  
end
