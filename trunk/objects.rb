object
  fix p(0,0,0)
  fix p(1,0,0)
  fix p(1,1,0)
  fix p(0,1,0)
  string 0,1
  string 1,2
  string 2,3
  string 3,0
  surface 0,1,2,3
  
  p(0.5, 0.5, 1)
end_object

gravity :all

return

object
  a = p(1,0,0)
  uni a, [0,0,1]
end_object

