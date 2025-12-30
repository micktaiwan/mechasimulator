class Console

  def initialize#(sw, sh)
    @queue = Array.new
    @num = 0
  end
  
  def push txt
    @num += 1
    @queue.shift if @queue.size >= 7  # Remove oldest from front
    @queue.push("#{@num}: #{txt}")    # Add newest to end (O(1) vs O(n))
  end

  def draw
    # Iterate in reverse: newest (last) displayed first at top
    @queue.reverse_each.with_index { |msg, y|
      if y == 0
        GL.Color3f(0.8, 0.8, 0.8)  # Newest message is bright
      else
        GL.Color3f(0.3, 0.3, 0.3)
      end
      text_out(10, 100 - y * 12, GLUT::BITMAP_HELVETICA_12, msg)
    }
  end

  def text_out(x, y, font, string)
    GL.RasterPos2f(x,y)
    string.each_byte do |c|
      GLUT.BitmapCharacter(font, c)
    end
  end


end

