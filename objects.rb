object :double_pendulum

  fix anchor = p(0, 0, 2)
  # plane anchor, :y, 0

  pend = p(1, 0, 2)
  s1 = string anchor, pend
  # plane pend, :y, 0

  pend2 = p(2, 0, 2)
  string pend, pend2
  # plane pend2, :y, 0

end_object

gravity :all

trace pend2

control 'o', [pend], :push_x, -0.005
control 'p', [pend], :push_x,  0.005
 