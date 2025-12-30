# Pendulum chain with almost-rigid springs
# Compare: left with rods, right with stiff springs
# Planar motion (Y=0), start at angle to see gravity

# Rod chain (left) - perfectly rigid
object :rod_chain
  15.times do |i|
    p(-1 + i*0.15, 0, 3 + i*0.1)  # Rising diagonal in XZ plane
    rod :last_two
  end
  fix :first
end_object

# Spring chain (right) - very stiff
object :spring_chain
  prev = nil
  15.times do |i|
    curr = p(1 + i*0.15, 0, 3 + i*0.1)  # Rising diagonal in XZ plane
    spring prev, curr, 1000, 10 if prev  # k=1000, c=10 (much stiffer)
    prev = curr
  end
  fix :first
end_object

gravity :all

console "Left (red): ROD chain"
console "Right (green): SPRING chain - k=1000, c=10"
