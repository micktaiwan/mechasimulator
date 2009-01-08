#################
# excavator arm #
#################

# first a base
object :lower
  box(v(1,1,0), v(1.2,2,1))
  mass 10
end_object

# then a (soon to be articulated) extension
object :upper
  box(v(1.2,1,1), v(2.2,2,1.2))
end_object

# join them together
join :lower, :upper, [1.2,1,1], [1.2,2,1] 

# then add some keyboard controlled hydrolic cylinder between the two
# first actuator
p1 = find_particle(:lower,[1,1,1])
p2 = find_particle(:upper,[1.2,1,1.2])
actuator1 = string p1, p2
# second actuator
p1 = find_particle(:lower,[1,2,1])
p2 = find_particle(:upper,[1.2,2,1.2])
actuator2 = string p1, p2
# controls
control 'o', [actuator1, actuator2], :add_length, -0.01
control 'p', [actuator1, actuator2], :add_length,  0.01

# we're done !
boundary :all, :z, :>, 0
gravity  :all

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

return

# a strange snake
object
  20.times do |i|
    p(-1+i*0.1,0,1)
    string :last_two
  end
  uni :first, [0,0,0.25]
  uni :last, [0,0,-0.2]
end_object

return

# monster
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

