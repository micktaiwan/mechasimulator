object

  fix a = p(-1, 0, 2)
  fix b = p(1, 0, 1)
  fix c = p(1.5, 0, 0.5)
  
  x = p(-1,0,0)
  
  gravit x,a
  gravit x,b
  gravit x,c

end_object

trace x, {:step=>5, :max=>100, :join=>true}
follow x

console "press 2 to toggle forces display"
