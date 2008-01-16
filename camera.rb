class Camera
  
  attr_accessor :pos, :view, :rot
  
  def initialize
    @pos  = {:x=>0,:y=>0.01, :z=>0.1}
    @view = {:x=>0,:y=>0, :z=>0}
    @rot  = {:x=>0,:y=>1, :z=>0}
  end
  
end
