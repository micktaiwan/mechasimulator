object
  ag  = p(0,1,0)
  ad  = p(0,-1,0)
  am  = p(0.6,0,0)
  am.set_mass(0.1)
  amf   = p(0.5,0,0)
  av  = p(2,0,0)
  av.set_mass(0.1)
  avf = p(2,0,0)
  h    = p(1,0,1)
  cam = p(-2,0,1)
  cam.set_mass(0.01)
  cami = p(-2.5,0,1)
  cami.set_mass(0.01)

  string cam,cami
  string ag,cam
  string ad,cam
  string h,cam
  string amf,cam

  string ag,avf
  string ad,avf
  string h,avf
  string amf,avf

  string ag,amf
  string ad,amf
  string ag,h
  string ad,h

  actuator1 = string ag, am
  actuator2 = string ad, am
  actuator3 = string ag, av
  actuator4 = string ad, av

end_object

gravit amf, am, {:factor=>10, :reverse=>true}
gravit avf, av, {:factor=>10, :reverse=>true}

boundary :all, :z, :>, 0
boundary cami, :z, :>, 1

gravity :all


control 'q', [actuator1, actuator3], :add_length, -0.05
control 'q', [actuator2, actuator4], :add_length, 0.05
control 'd', [actuator2,actuator4], :add_length, -0.05
control 'd', [actuator1,actuator3], :add_length, 0.05

control 'z', [actuator1,actuator2], :add_length, 0.04
control 's', [actuator1,actuator2], :add_length, -0.04

follow avf, {:position=>cami}
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

