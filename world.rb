module World
  
  # placez vos objects dans cette methode
  def load_world
    print 'Chargement du monde... '
    
    # un cube
    cube = ODE::Box.new(25,2,0.2,@space) # n'oubliez pas @space, je changerai ca plus tard
    cube.position = [2,2,0]
    cube.rotation = [45,45,45] # les rotations sont dependantes aujourd'hui... d'abord x ensuite y ensuite z
    
    # ... et c'est tout ce qu'on peut faire aujourd'hui
    puts 'fini'
  end
  
end
