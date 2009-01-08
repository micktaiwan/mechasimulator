#################
# excavator arm #
#################

# first a base
object :lower
  box(v(1,1,0), v(1.2,2,1))
  fix 0
  fix 1
  fix 2
  fix 3
  mass 100
end_object

# then a (soon to be articulated) extension
object :upper
  box(v(1.2,1,1), v(2.2,2,1.2))
end_object

# and another one
object :end
  box(v(2.2,1,0.5), v(2.4,2,1))
end_object

# join them together
join :lower, :upper, [1.2,1,1], [1.2,2,1] 
join :upper, :end,   [2.2,1,1], [2.2,2,1] 

# then add some keyboard controlled hydrolic cylinder between the two
p1 = find_particle(:lower,[1,1,1])
p2 = find_particle(:upper,[1.2,1,1.2])
actuator1 = string p1, p2
p1 = find_particle(:lower,[1,2,1])
p2 = find_particle(:upper,[1.2,2,1.2])
actuator2 = string p1, p2

#p1 = find_particle(:upper,[2.2,1,1.2])
#p2 = find_particle(:end,[2.4,1,1])
#actuator3 = string p1, p2
#p1 = find_particle(:upper,[2.2,2,1.2])
#p2 = find_particle(:end,[2.4,2,1])
#actuator4 = string p1, p2
# controls
control 'o', [actuator1, actuator2], :add_length, -0.01
control 'p', [actuator1, actuator2], :add_length,  0.01

#control 'l', [actuator3, actuator4], :add_length, -0.01
#control 'm', [actuator3, actuator4], :add_length,  0.01


# we're done !
boundary :all, :z, :>, 0
#gravity  :all

follow find_particle(:end,[2.4,2,1])

