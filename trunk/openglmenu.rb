require 'menu_config'

class OpenGLMenu

  def initialize
    @level = :main
  end

  def draw
    items = MENU[@level]
    items.each_with_index { |i, index|
        text_out(100,100+index*20, GLUT_BITMAP_HELVETICA_18, i[1])
      }
  end
  
  def text_out(x, y, font, string)  
    GL::RasterPos2f(x,y)
    string.each_byte do |c|
      GLUT::BitmapCharacter(font, c)
    end
  end

  
end

