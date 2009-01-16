object

  a = p(-1, 0, 2)
  b = p(1, 0, 2)
  c = p(0.2, 0, 1)

  gravit a,b
  gravit b,a

  gravit a,c
  gravit c,a
  
  gravit b,c
  gravit c,b
  
end_object

trace a


return


object

  fix a = p(-1, 0, 0)
  fix b = p(1, 0, 0)
  fix c = p(0, 2, 0)

  j = p(0,0.75,1)
  
  string a,j
  string b,j
  s1 = string c,j
  
  
  pend = p(0,0.75, 0.5)
  string pend,j
  
  surface a,j,b
  surface b,j,c
  surface c,j,a
  

end_object

gravity :all

control 'o', [s1], :add_length, -0.05
control 'p', [s1], :add_length,  0.05
 