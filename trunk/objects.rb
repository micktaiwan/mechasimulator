object
  a = p(0,0,1)
  uni :last, [0, 0, 0.01]
  p(1,0,1)
  gravit :last, a, {:factor=>20, :inverse=>true}
end_object

