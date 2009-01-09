#!/usr/bin/ruby
#require 'profile'
require 'config'
require 'world'
require 'particle_system'
require 'dsl'
require 'controls'
require 'joy'

class PlaneWorld < World
  
  def draw
    t = GLUT.Get(GLUT::ELAPSED_TIME)
    # clear
    GL.Clear(GL::COLOR_BUFFER_BIT | GL::DEPTH_BUFFER_BIT)
    GL::LoadIdentity()
    
    # camera
    GL.Rotate(@cam.rot.x, 1.0, 0.0, 0.0)
    GL.Rotate(@cam.rot.y, 0.0, 1.0, 0.0)
    GL.Rotate(@cam.rot.z, 0.0, 0.0, 1.0)
    GL.Translate(-@cam.pos.x, -@cam.pos.y, -@cam.pos.z)

    # ground
    GL.CallList(@ground_list)

    # ps
    if(@editing)
      if(t - @t0 >= 1000)
        d = File.stat('objects.rb').mtime
        if d != @old_file_stat
          @dsl.reload # reload objects
          @old_file_stat = d
        end
      end
    else
      @controls.joy if @joy.present?
      @ps.next_step
    end

    # draw particles and forces
    GL::PointSize(CONFIG[:draw][:point_size])
    GL::LineWidth(3)
    @ps.particles.each { |p|
      # particles
      GL::Color(0.6, 0.6, 0.6)
      GL::Begin(GL::POINTS)
        v(p.current.x,p.current.y,p.current.z)
      GL::End()
      next if not CONFIG[:draw][:forces]
      # forces
      p.forces.each { |f|
        next if f.type == :gravity
        case f.type
        when :motor
          GL::Color(0.2, 0.8, 0.2)
        when :uni
          GL::Color(0.2, 0.2, 0.8)
        else
          GL::Color(0.8, 0.4, 0.2)
        end
        v = p.current+(f.vector)#/(9.81*2))
        GL::Begin(GL::LINES)
          v(p.current.x,p.current.y,p.current.z)
          v(v.x,v.y,v.z)
        GL::End()
        }
      }
    GL::PointSize(1)
    GL::LineWidth(1)

    # draw constraints
    if(CONFIG[:draw][:constraints])
      GL::Color(1,0,0)
      @ps.constraints.each { |c|
        next if c.type != :string
        GL::Begin(GL::LINES)
          p = c.particles[0]
          v(p.current.x,p.current.y,p.current.z)
          p = c.particles[1]
          v(p.current.x,p.current.y,p.current.z)
        GL::End()
        }
    end
    
    # board
    #draw_board
    
    draw_console

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
    
    @cam.follow if CONFIG[:cam][:follow]
   
    if t - @t0 >= 1000
      seconds = (t - @t0) / 1000.0
      @fps = @frames / seconds
      @ps.time_step = 1/@fps
      @t0, @frames = t, 0
      exit if defined? @autoexit and t >= 999.0 * @autoexit
    end
  end
  
  def key(k, x, y)
    @controls.action(k.chr,1)
    case k
      when 13 # Enter
        @editing = @editing==true ? nil : true
      when 8 # Backspace
        @dsl.reload
      when 32 # space
        CONFIG[:draw][:constraints] = CONFIG[:draw][:constraints]? nil : true
      when '1'[0]
        CONFIG[:cam][:follow] = CONFIG[:cam][:follow]? nil : true
      when '2'[0]
        CONFIG[:draw][:forces] = CONFIG[:draw][:forces]? nil : true
    end
    super
  end

  def special(k, x, y)
    case k
      when GLUT::KEY_UP
        @cam.pos.y += 1 
      when GLUT::KEY_DOWN
        @cam.pos.y -= 1 
      when GLUT::KEY_LEFT
        @cam.pos.x -= 1 
      when GLUT::KEY_RIGHT
        @cam.pos.x += 1 
    end
    super
  end
  
  def init
    GLUT.InitDisplayMode(GLUT::RGBA | GLUT::DEPTH | GLUT::DOUBLE)
    GLUT.InitWindowPosition(0, 0)
    f = 4
    GLUT.InitWindowSize(320*f,240*f)
    GLUT.CreateWindow('mecha')
    GL.ClearColor(0.0, 0.0, 0.0, 0.0)
    GL.ShadeModel(GL::SMOOTH)
    GL.DepthFunc(GL::LEQUAL)
    GL.Hint(GL::PERSPECTIVE_CORRECTION_HINT, GL::NICEST)
    GL.Enable(GL::DEPTH_TEST)
    GL.Enable(GL::NORMALIZE)
    GL::Enable(GL::POINT_SMOOTH);

    @ground_list = GL.GenLists(1)
    GL.NewList(@ground_list, GL::COMPILE)
      draw_grid
    GL.EndList()

    @ps = ParticleSystem.new
    @joy = Joy.new(CONFIG[:joy][:dev])
    @controls = Controls.new(@joy)
    @dsl = DSL.new(@ps, @console, @controls, @cam)
    @dsl.reload 
    @editing= nil
    @old_file_stat = nil

    err = GL.GetError
    raise "GL Error code: #{err}" if err != 0
  end

  
private  


  def draw_board
    enable_2D
    GL::Color(0, 1, 0)
    #draw_control(0, @plane.inputs[:thrust], 10)
    #draw_control(1, @plane.lift.length, 0.01)
    #draw_control(2, @plane.drag.length, 0.01)
    #draw_control(3, @plane.gravity.length, 0.01)
    disable_2D
  end
  
  def draw_console
    enable_2D
    # FPS
    GL::Color(1, 1, 0)
    @console.text_out(10,@screen_height-30, GLUT_BITMAP_HELVETICA_18, @fps.to_i.to_s + " fps")
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
