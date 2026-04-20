# Solar System Simulation
# Sun at center with planets in orbit using gravitational attraction and motors

# Sun - fixed at center
object :sun
  sun = p(0, 0, 0, 1000)  # Large mass
  fix sun
end_object

# Mercury - closest to sun
object :mercury
  mercury = p(0.8, 0, 0, 0.1)
  gravit mercury, find_particle(:sun, [0,0,0]), factor: 50
  motor mercury, [0,0,0], [0,0,1], 2.5
end_object

# Venus
object :venus
  venus = p(1.2, 0, 0, 0.3)
  gravit venus, find_particle(:sun, [0,0,0]), factor: 50
  motor venus, [0,0,0], [0,0,1], 1.8
end_object

# Earth
object :earth
  earth = p(1.6, 0, 0, 0.4)
  gravit earth, find_particle(:sun, [0,0,0]), factor: 50
  motor earth, [0,0,0], [0,0,1], 1.5
end_object

# Mars
object :mars
  mars = p(2.0, 0, 0, 0.2)
  gravit mars, find_particle(:sun, [0,0,0]), factor: 50
  motor mars, [0,0,0], [0,0,1], 1.2
end_object

# Jupiter - largest planet
object :jupiter
  jupiter = p(3.0, 0, 0, 2.0)
  gravit jupiter, find_particle(:sun, [0,0,0]), factor: 50
  motor jupiter, [0,0,0], [0,0,1], 0.8
end_object

# Saturn
object :saturn
  saturn = p(4.0, 0, 0, 1.5)
  gravit saturn, find_particle(:sun, [0,0,0]), factor: 50
  motor saturn, [0,0,0], [0,0,1], 0.6
end_object

# Uranus
object :uranus
  uranus = p(5.0, 0, 0, 0.8)
  gravit uranus, find_particle(:sun, [0,0,0]), factor: 50
  motor uranus, [0,0,0], [0,0,1], 0.45
end_object

# Neptune - farthest planet
object :neptune
  neptune = p(6.0, 0, 0, 0.9)
  gravit neptune, find_particle(:sun, [0,0,0]), factor: 50
  motor neptune, [0,0,0], [0,0,1], 0.35
end_object

# Moon orbiting Earth
object :moon
  moon = p(1.8, 0, 0, 0.05)
  gravit moon, find_particle(:earth, [1.6,0,0]), factor: 5
  motor moon, [1.6,0,0], [0,0,1], 3.0
end_object

# Trace planet trajectories for visualization
# trace find_particle(:mercury, [0.8,0,0])
# trace find_particle(:venus, [1.2,0,0])
# trace find_particle(:earth, [1.6,0,0])
# trace find_particle(:mars, [2.0,0,0])
# trace find_particle(:jupiter, [3.0,0,0])
# trace find_particle(:saturn, [4.0,0,0])
# trace find_particle(:uranus, [5.0,0,0])
# trace find_particle(:neptune, [6.0,0,0])

# Lock all planets to the orbital plane (z=0)
plane :all, :z, 0

console "Solar System Simulation"
console "8 planets orbiting the Sun"
console "Press Space to toggle constraints"
