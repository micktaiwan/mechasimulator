# box
object
  
  box(v(1,1,1), v(1.2,2,2))
  #fix :first
  boundary :all, :z, :>, 0
  gravity  :all

end_object

return

# a necklace
object
  20.times do |i|
    p(2,-1+i*0.1,3)
    string :last_two # do nothing if no two last elements
  end
  fix   :first
  gravity :all
end_object


object
  head = p(0,1,2)
  fix head
  
  l1   = p(1,2,1.7)
  l2   = p(-1,2,1.7)
  string head, l1
  string head, l2
  
  l3    = p(0,2,1)
  l3.set_mass 0.001
  string l1,l3
  string l2,l3
  

  #motor l1, head, [0,1,0], -1
  uni   l2, [0,0,1]
  motor l3, head, [0,0,1], 3

  #gravity :all
end_object

