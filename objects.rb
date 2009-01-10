object
  nb = 150
  nb.times do |i|
    xp = Math::cos(i*Math::PI/10)
    yp = Math::sin(i*Math::PI/10)
    pt = p(xp,yp,0)
    pt.set_mass(150/(i+1))
    string :last_two
    gravit -2, -1, {:factor=>-i/10, :reverse=>true} if i > 0
  end
end_object
