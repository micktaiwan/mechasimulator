object

  p(-1,0,2)
  p(-2,0,2)
  p(-2,0,0)
  p(3,0,0)
  p(3,0,1)

  p(-1,2,2)
  p(1,2,2)
  p(-1,2,0)
  p(3,2,0)  
  p(3,2,1)      

  string 0,1
  string 1,4
  string 3,4
  string 2,3
  string 0,2
  string 5,6
  string 5,7
  string 6,9
  string 9,8
  string 7,8
  string 7,2
  string 5,0
  string 6,1
  string 9,4
  string 8,3
  string 8,7

end_object

#gravity :all

return


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
 
