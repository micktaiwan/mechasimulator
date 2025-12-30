
class TraceList

  def initialize
    @traces = []
  end

  def add(p,opt)
    @traces << Trace.new(p,opt)
  end

  def record
    @traces.each {|t| t.record}
  end

  def trace
    @traces.each {|t| t.trace}
  end

  def clear
    @traces.clear
    #@traces.each {|t| t.clear}
  end

end

# trace particle paths
class Trace

  def initialize(p, opt)
    @particle = p
    @points   = []
    @step     = (opt and opt[:step]) || 10
    @max      = (opt and opt[:max]) || 100
    @join     = (opt and opt[:join])
    @last     = 0
  end

  def record
    if(@last==0)
      @points << @particle.current.to_a
      @points.shift if @points.size > @max
      @last = @step
    end
    @last -= 1
  end

  def trace
    GL.PointSize(2)
    GL.LineWidth(1)
    @points.each_with_index { |p, i|
      # particles
      GL.Color3f(0.6, 0.6, 0.6)
      GL.Begin(GL::POINTS)
        GL.Vertex3d(p[0],p[1],p[2])
      GL.End()
      next if not @join or i == 0
      GL.Color3f(0.4, 0.4, 0.4)
      GL.Begin(GL::LINES)
        GL.Vertex3d(p[0],p[1],p[2])
        GL.Vertex3d(@points[i-1][0],@points[i-1][1],@points[i-1][2])
      GL.End()
      }
  end

  def clear
    @points.clear
    @last = 0
  end

end
