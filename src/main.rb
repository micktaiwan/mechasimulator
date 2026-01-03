#!/opt/homebrew/opt/ruby/bin/ruby
#require 'profile'
gem 'opengl-bindings2'
require_relative '../config'
require_relative 'world'
require_relative 'particle_system'
require_relative 'dsl'
require_relative 'controls'
require_relative 'joy'
require_relative 'trace'
require_relative 'openglmenu'

class PlaneWorld < World

  attr_accessor :ps, :cam, :controls, :console, :traces
  
  def draw
    t = GLUT.Get(GLUT::ELAPSED_TIME)
    @dt = (t - @last_frame_time) / 1000.0  # delta time in seconds
    @last_frame_time = t
    # clear
    GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
    GL.LoadIdentity()
    
    # camera
    GL.Rotatef(@cam.rot.x, 1.0, 0.0, 0.0)
    GL.Rotatef(@cam.rot.y, 0.0, 1.0, 0.0)
    GL.Rotatef(@cam.rot.z, 0.0, 0.0, 1.0)
    GL.Translatef(-@cam.pos.x, -@cam.pos.y, -@cam.pos.z)

    # ground
    GL.CallList(@ground_list)
    draw_arrows if CONFIG[:draw][:axes]

    # ps
    if(@editing)
      if(t - @t0 >= 1000)
        d = File.stat(File.expand_path('../objects.rb', __dir__)).mtime
        if d != @old_file_stat
          @dsl.reload # reload objects
          @old_file_stat = d
        end
      end
    else
      @controls.joy if @joy.present?
      # Use fixed timestep for stable physics (variable dt breaks Verlet energy conservation)
      @ps.time_step = 1/60.0 / CONFIG[:ps][:speed_factor]
      @ps.next_step
      @traces.record
      @traces.trace
    end
    draw_console
    enable_2D
    @menu.draw if CONFIG[:draw][:menu]
    disable_2D

    # draw particles and forces
    GL.PointSize(CONFIG[:draw][:point_size])
    GL.LineWidth(3)
    @ps.particles.each { |p|
      # particles
      GL.Color4f(0.6, 0.6, 0.6, 1.0)
      GL.Begin(GL::POINTS)
        v(p.current.x,p.current.y,p.current.z)
      GL.End()
      next if not CONFIG[:draw][:forces]
      # forces
      p.forces.each { |f|
        next if f.type == :gravity
        case f.type
        when :motor
          GL.Color4f(0.2, 0.8, 0.2, 1.0)
        when :uni
          GL.Color4f(0.2, 0.2, 0.8, 1.0)
        else
          GL.Color4f(0.8, 0.4, 0.2, 1.0)
        end
        v = p.current+(f.vector)#/(9.81*2))
        GL.Begin(GL::LINES)
          v(p.current.x,p.current.y,p.current.z)
          v(v.x,v.y,v.z)
        GL.End()
        }
      }
    GL.PointSize(1)
    GL.LineWidth(1)

    # draw constraints (rods in red)
    if(CONFIG[:draw][:constraints])
      GL.Color4f(1.0, 0.0, 0.0, 1.0)
      @ps.constraints.each { |c|
        next if c.type != :rod
        GL.Begin(GL::LINES)
          p = c.particles[0]
          v(p.current.x,p.current.y,p.current.z)
          p = c.particles[1]
          v(p.current.x,p.current.y,p.current.z)
        GL.End()
        }

      # draw springs (in green)
      GL.Color4f(0.0, 1.0, 0.0, 1.0)
      @ps.springs.each { |s|
        GL.Begin(GL::LINES)
          v(s.p1.current.x, s.p1.current.y, s.p1.current.z)
          v(s.p2.current.x, s.p2.current.y, s.p2.current.z)
        GL.End()
        }
    end
    
    # board
    #draw_board
    

    # END
    GLUT.SwapBuffers()

    @frames += 1
    
    if CONFIG[:cam][:rotate] > 0
      x = @cam.pos.x = Math.cos(t/5000.0)*CONFIG[:cam][:rotate]
      y = @cam.pos.y = Math.sin(t/5000.0)*CONFIG[:cam][:rotate]
      scale = 45/Math.atan(1) 
      a = (scale*Math.atan2(y,x))+90
      @cam.rot.z = -a
    end
    
    # done after rotate so the cam still follow if told to do so
    @cam.accelerate(@cam_acceleration) if @keys[:forward]
    @cam.accelerate(-@cam_acceleration) if @keys[:backward]
    @cam.elevate(@cam_acceleration) if @keys[:pitch_up]      # E = monter
    @cam.elevate(-@cam_acceleration) if @keys[:pitch_down]   # A = descendre
    @cam.turn(-@cam_turn_speed) if @keys[:left]
    @cam.turn(@cam_turn_speed) if @keys[:right]
    @cam.strafe(-@cam_acceleration) if @keys[:strafe_left]
    @cam.strafe(@cam_acceleration) if @keys[:strafe_right]
    @cam.pitch(@cam_turn_speed) if @keys[:down]              # Flèche bas = regarder en bas
    @cam.pitch(-@cam_turn_speed) if @keys[:up]               # Flèche haut = regarder en haut
    @cam.update(@dt)
    @cam.follow if CONFIG[:cam][:follow]

    # Apply held controls from objects.rb
    @keys.each { |k, pressed| @controls.action(k, 1) if pressed && k.is_a?(String) }
   
    if t - @t0 >= 1000
      seconds = (t - @t0) / 1000.0
      @fps = @frames / seconds
      @t0, @frames = t, 0
      exit if defined? @autoexit and t >= 999.0 * @autoexit
    end
  end
  
  def key(k, x, y)
    chr = k.chr.downcase rescue nil
    @keys[chr] = true if chr
    @keys[:forward] = true if chr == CONFIG[:cam][:key_forward]
    @keys[:backward] = true if chr == CONFIG[:cam][:key_backward]
    @keys[:strafe_left] = true if chr == CONFIG[:cam][:key_strafe_left]
    @keys[:strafe_right] = true if chr == CONFIG[:cam][:key_strafe_right]
    @keys[:pitch_down] = true if chr == CONFIG[:cam][:key_pitch_down]
    @keys[:pitch_up] = true if chr == CONFIG[:cam][:key_pitch_up]
    if CONFIG[:draw][:menu]
      rv = @menu.key(k)
      CONFIG[:draw][:menu] = nil if rv == :quit
      return
    end
    @controls.action(k.chr,1)
    case k
      when 13 # Enter
        @editing = @editing==true ? nil : true
      when 8, 127 # Backspace (8 on Linux/Windows, 127 on macOS)
        @dsl.reload
      when 32 # space
        CONFIG[:draw][:constraints] = CONFIG[:draw][:constraints]? nil : true
      when '1'.ord
        CONFIG[:cam][:follow] = CONFIG[:cam][:follow]? nil : true
      when '2'.ord
        CONFIG[:draw][:forces] = CONFIG[:draw][:forces]? nil : true
      when 'f'.ord, 'F'.ord
        toggle_fullscreen
    end
    super
  end

  def key_up(k, x, y)
    chr = k.chr.downcase rescue nil
    @keys[chr] = false if chr
    @keys[:forward] = false if chr == CONFIG[:cam][:key_forward]
    @keys[:backward] = false if chr == CONFIG[:cam][:key_backward]
    @keys[:strafe_left] = false if chr == CONFIG[:cam][:key_strafe_left]
    @keys[:strafe_right] = false if chr == CONFIG[:cam][:key_strafe_right]
    @keys[:pitch_down] = false if chr == CONFIG[:cam][:key_pitch_down]
    @keys[:pitch_up] = false if chr == CONFIG[:cam][:key_pitch_up]
  end

  def toggle_fullscreen
    @fullscreen = !@fullscreen
    if @fullscreen
      GLUT.FullScreen()
    else
      GLUT.PositionWindow(0, 0)
      GLUT.ReshapeWindow(@screen_width, @screen_height)
    end
  end

  def special(k, x, y)
    @keys[:up] = true if k == GLUT::KEY_UP
    @keys[:down] = true if k == GLUT::KEY_DOWN
    @keys[:left] = true if k == GLUT::KEY_LEFT
    @keys[:right] = true if k == GLUT::KEY_RIGHT
    case k
      when GLUT::KEY_F1
        CONFIG[:draw][:menu] = CONFIG[:draw][:menu]? nil : true
    end
    super
  end

  def special_up(k, x, y)
    @keys[:up] = false if k == GLUT::KEY_UP
    @keys[:down] = false if k == GLUT::KEY_DOWN
    @keys[:left] = false if k == GLUT::KEY_LEFT
    @keys[:right] = false if k == GLUT::KEY_RIGHT
  end
  
  def init
    GLUT.InitDisplayMode(GLUT::RGBA | GLUT::DEPTH | GLUT::DOUBLE)
    # Get screen size for maximized window
    @screen_width = GLUT.Get(GLUT::SCREEN_WIDTH)
    @screen_height = GLUT.Get(GLUT::SCREEN_HEIGHT)
    @fullscreen = false
    GLUT.InitWindowPosition(0, 0)
    GLUT.InitWindowSize(@screen_width, @screen_height)
    GLUT.CreateWindow('mecha')

    # Load GL after window/context is created
    GL.load_lib

    GL.ClearColor(0.0, 0.0, 0.0, 0.0)
    GL.ShadeModel(GL::SMOOTH)
    GL.DepthFunc(GL::LEQUAL)
    GL.Hint(GL::PERSPECTIVE_CORRECTION_HINT, GL::NICEST)
    GL.Enable(GL::DEPTH_TEST)
    GL.Enable(GL::NORMALIZE)
    GL.Enable(GL::POINT_SMOOTH)
    GL.Enable(GL::BLEND) # for the menu


    @ground_list = GL.GenLists(1)
    GL.NewList(@ground_list, GL::COMPILE)
      draw_grid
    GL.EndList()

    @ps       = ParticleSystem.new
    @joy      = Joy.new(CONFIG[:joy][:dev])
    @controls = Controls.new(@joy)
    @traces   = TraceList.new
    @menu     = OpenGLMenu.new
    @editing  = nil
    @old_file_stat = nil
    @dsl      = DSL.new(self) #, @ps, @console, @controls, @cam)
    @dsl.reload
    @keys     = {}
    @last_frame_time = GLUT.Get(GLUT::ELAPSED_TIME)
    @dt = 1.0/60.0

    # Callbacks for key release
    @special_up_callback = GLUT.create_callback(:GLUTSpecialUpFunc) { |k, x, y| special_up(k, x, y) }
    GLUT.SpecialUpFunc(@special_up_callback)
    @key_up_callback = GLUT.create_callback(:GLUTKeyboardUpFunc) { |k, x, y| key_up(k, x, y) }
    GLUT.KeyboardUpFunc(@key_up_callback)

    # Cache CONFIG values for hot loop performance
    @cam_acceleration = CONFIG[:cam][:acceleration]
    @cam_turn_speed = CONFIG[:cam][:turn_speed]

    err = GL.GetError
    raise "GL Error code: #{err}" if err != 0
  end

  
private  


  def draw_board
    enable_2D
    GL.Color4f(0, 1, 0, 1)
    #draw_control(0, @plane.inputs[:thrust], 10)
    #draw_control(1, @plane.lift.length, 0.01)
    #draw_control(2, @plane.drag.length, 0.01)
    #draw_control(3, @plane.gravity.length, 0.01)
    disable_2D
  end
  
  def draw_console
    enable_2D
    # FPS
    GL.Color4f(1, 1, 0, 1)
    @console.text_out(10,@screen_height-30, GLUT::BITMAP_HELVETICA_18, @fps.to_i.to_s + " fps")
    # Energy (update display only every 30 frames)
    @energy_frame_count ||= 0
    @energy_frame_count += 1
    if @energy_frame_count >= 30
      @energy_frame_count = 0
      @cached_energy = @ps.total_energy
    end
    @cached_energy ||= @ps.total_energy
    @console.text_out(10,@screen_height-50, GLUT::BITMAP_HELVETICA_18,
      "E:%.1f K:%.1f P:%.1f" % [@cached_energy[:total], @cached_energy[:kinetic], @cached_energy[:potential]])
    @console.draw
    disable_2D
  end

  def draw_control(place, value, max)
    GL.Begin(GL::LINE_LOOP)
      GL.Vertex2f(10+place*25, 2)
      GL.Vertex2f(30+place*25, 2)
      GL.Vertex2f(30+place*25, 82)
      GL.Vertex2f(10+place*25, 82)
    GL.End()
    GL.Begin(GL::QUADS)
      GL.Vertex2f(10+place*25, 2+(value/max.to_f)*80)
      GL.Vertex2f(30+place*25, 2+(value/max.to_f)*80)
      GL.Vertex2f(30+place*25, 2)
      GL.Vertex2f(10+place*25, 2)
    GL.End()
  end

end

PlaneWorld.new.start
