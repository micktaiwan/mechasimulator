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
    #puts 'update'
    # camera
    GL::Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
    GL::LoadIdentity()
    GLU::LookAt(@model.cam.pos.x, @model.cam.pos.y, @model.cam.pos.z,
                @model.cam.view.x,@model.cam.view.y,@model.cam.view.z,
                @model.cam.rot.x, @model.cam.rot.y, @model.cam.rot.z)
    
    # draw geometries
    @model.space.each_geom { |geom|
      puts geom.position.to_s  if CONFIG[:log][:pos]
      geom.draw
    }
    
    #draw_test
    GL::CallList(@grid_id)
    draw_axes
    
    # swap buffers
    Rubygame::GL.swap_buffers()
    
  end
  
  private
  
  
  #  def define(r)
  #    x = r[0]; y = r[1]; z = r[2]; w = r[3]
  #    sqw = w*w
  #    sqx = x*x
  #    sqy = y*y
  #    sqz = z*z
  #    unit = sqx + sqy + sqz + sqw # if normalised is one, otherwise is correction factor
  #    test = x*y + z*w
  #    if (test > 0.499*unit) # singularity at north pole
  #      @heading = 2 * Math.atan2(x,w)
  #      @attitude = Math::PI/2
  #      @bank = 0
  #      return
  #    end
  #    if (test < -0.499*unit) # singularity at south pole
  #      @heading = -2 * Math.atan2(x,w)
  #      @attitude = -Math::PI/2
  #      @bank = 0
  #      return
  #    end
  #    @heading = Math.atan2(2*y*w-2*x*z , sqx - sqy - sqz + sqw)
  #    @attitude = Math.asin(2*test/unit)
  #    @bank = Math.atan2(2*x*w-2*y*z , -sqx + sqy - sqz + sqw)
  #  end
  
  
  #  def draw_simple_box(x,y,w)
  #    GL::Begin(GL::QUADS)
  #    GL::Vertex(x, w)
  #    GL::Vertex(x, y+w)
  #    GL::Vertex(x+w, y+w)
  #    GL::Vertex(x+w, y)
  #    GL::End()
  #  end
  
  def screen_make(wide, high, fullscreen = false, doublebuf = true) 
    flags = [Rubygame::HWSURFACE, Rubygame::ANYFORMAT, Rubygame::OPENGL]
    flags << Rubygame::FULLSCREEN if fullscreen
    flags << Rubygame::DOUBLEBUF  if doublebuf
    screen = Rubygame::Screen.set_mode([wide, high], 16, flags )
    #screen.title = 'Robot Simulator'
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
    
    # grid list
    @grid_id = GL::GenLists(1);
    GL::NewList(@grid_id,GL::COMPILE)
    draw_grid
    GL::EndList()
    
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
