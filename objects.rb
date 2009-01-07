# box
object

  p(0,0,2)
  p(1,0,2)
  p(1,2,2)
  p(0,2,2)

  fix p(0,0,2.5)
  fix p(1,0,2.5)
  p(1,2,2.5)
  p(0,2,2.5)

  string 0,4
  string 1,5
  string 2,6
  string 3,7

  string 0,1
  string 1,2
  string 2,3
  string 3,0

  string 4,5
  string 5,6
  string 6,7
  string 7,4

  string 0,6
  string 1,7
  string 2,4
  string 3,5

  boundary :all, :z, :>, 0
  gravity  :all

end_object

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

