# Example 3 : Piston

object
  c = p(0,0,1)
  fix c
  f = p(1,0,1)
  p(0,0,3)
  
  fix from = p(-5,-4,1)

  string 0,1
  string 1,2
  boundary 2, :x, :>, -0.01
  boundary 2, :x, :<,  0.01
  boundary 2, :y, :>, -0.01
  boundary 2, :y, :<,  0.01

  motor 1, c, [0,1,0], -9.82
end_object

gravity :all
follow f, {:position=>from}



