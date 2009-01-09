
object
  a = p(0,0,1)
  uni :last, [0, 0, 0.01]
  p(2,0,1)
  gravit :last, a, {:factor=>0.1, :reverse=>nil}
end_object

