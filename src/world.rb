require 'opengl'
require 'glut'
require_relative 'camera'
require_relative 'console'

class World

  def draw
    raise 'override draw'
  end

  def idle
    GLUT.PostRedisplay()
  end

  def key(k, x, y)
    case k
      when 27 # Escape
        exit
    end
    GLUT.PostRedisplay()
  end

  def special(k, x, y)
    GLUT.PostRedisplay()
  end

  # New window size or exposure
  def reshape(width, height)
    @screen_width  = width
    @screen_height = height
    h = height.to_f / width.to_f
    GL.Viewport(0, 0, width, height)
    GL.MatrixMode(GL::PROJECTION)
    GL.LoadIdentity()
    GL.Frustum(-1.0, 1.0, -h, h, 1.5, 60.0)
    #GLU.Perspective(@fov, h, 0.1, 60.0)
    GL.MatrixMode(GL::MODELVIEW)
    GL.LoadIdentity()
  end

  def init
    raise 'override init'
  end

  def enable_2D
    viewport_buf = ' ' * 16
    GL.GetIntegerv(GL::VIEWPORT, viewport_buf)
    vPort = viewport_buf.unpack('i4')

    GL.MatrixMode(GL::PROJECTION)
    GL.PushMatrix()
    GL.LoadIdentity()

    GL.Ortho(0, vPort[2], 0, vPort[3], -1, 1)
    GL.MatrixMode(GL::MODELVIEW)
    GL.PushMatrix()
    GL.LoadIdentity()
  end

  def disable_2D
    GL.MatrixMode(GL::PROJECTION)
    GL.PopMatrix()
    GL.MatrixMode(GL::MODELVIEW)
    GL.PopMatrix()
  end

  def visible(vis)
    if vis == GLUT::VISIBLE
      GLUT.IdleFunc(@idle_callback)
    else
      GLUT.IdleFunc(nil)
    end
  end

  def mouse(button, state, x, y)
    @mouse = state
    @x0, @y0 = x, y
  end

  def motion(x, y)
    if @mouse == GLUT::DOWN
      nx = (@x0 - x).to_f * CONFIG[:mouse][:speed_factor]
      nz = (@y0 - y).to_f * CONFIG[:mouse][:speed_factor]
      @cam.move(0, nz, nx)
    end
    @x0, @y0 = x, y
  end

  def v(x,y,z)
    GL.Vertex3d(x,y,z)
  end

  def draw_grid
    GL.Begin(GL::LINES)
      GL.Color4f(0.3,0.3,0.3, 1)
      x = 40
      x.times do |i|
        v(i-x/2,-x/2,0)
        v(i-x/2,x/2,0)
        v(-x/2,i-x/2,0)
        v(x/2,i-x/2,0)
      end
    GL.End()
  end

  def draw_arrows
    GL.LineWidth(3)
    GL.Begin(GL::LINES)
    GL.Color4f(1, 0, 0, 1)
    v(0,0,0)
    v(1,0,0)
    GL.Color4f(0, 1, 0, 1)
    v(0,0,0)
    v(0,1,0)
    GL.Color4f(0, 0, 1, 1)
    v(0,0,0)
    v(0,0,1)
    GL.End()
    GL.LineWidth(1)
  end

  def initialize(fov = 90.0)
    @fov    = fov
    @angle  = 0.0
    @frames = 0
    @t0     = 0
    @cam    = Camera.new
    @fps = 0
    @console = Console.new

    # Load GLUT library
    GLUT.load_lib

    # Initialize GLUT
    argc = [0].pack('I')
    argv = [''].pack('p')
    GLUT.Init(argc, argv)

    # Call subclass init (creates window and loads GL)
    init()

    # Create callbacks
    @display_callback = GLUT.create_callback(:GLUTDisplayFunc) { draw }
    @reshape_callback = GLUT.create_callback(:GLUTReshapeFunc) { |w, h| reshape(w, h) }
    @keyboard_callback = GLUT.create_callback(:GLUTKeyboardFunc) { |k, x, y| key(k, x, y) }
    @special_callback = GLUT.create_callback(:GLUTSpecialFunc) { |k, x, y| special(k, x, y) }
    @visibility_callback = GLUT.create_callback(:GLUTVisibilityFunc) { |vis| visible(vis) }
    @mouse_callback = GLUT.create_callback(:GLUTMouseFunc) { |btn, state, x, y| mouse(btn, state, x, y) }
    @motion_callback = GLUT.create_callback(:GLUTMotionFunc) { |x, y| motion(x, y) }
    @idle_callback = GLUT.create_callback(:GLUTIdleFunc) { idle }

    # Register callbacks
    GLUT.DisplayFunc(@display_callback)
    GLUT.ReshapeFunc(@reshape_callback)
    GLUT.KeyboardFunc(@keyboard_callback)
    GLUT.SpecialFunc(@special_callback)
    GLUT.VisibilityFunc(@visibility_callback)
    GLUT.MouseFunc(@mouse_callback)
    GLUT.MotionFunc(@motion_callback)
  end

  def start
    GLUT.MainLoop()
  end

end
