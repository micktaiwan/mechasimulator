object
    box([0,0,0], [1,1,1])
end_object

return

object
  a = p(0,0,1)
  uni a, [0, 0, -9.81]
  b = p(1,0,1)
end_object

return

object
  a = p(0,0,1)
  uni :last, [0, 0, 0.01]
  p(2,0,1)
  gravit :last, a, {:factor=>0.1, :reverse=>nil}
end_object

