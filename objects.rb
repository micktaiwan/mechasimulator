object
  a = p(0,0,1)
  uni a, [0,0,0.1]
  
  b = p(2,0,1)
  gravit b, a, {:factor=>2, :inverse=>true}
end_object

#gravity :all
#boundary :all, :z, :>, 0

