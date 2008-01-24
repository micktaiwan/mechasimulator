module World
  
  # placez vos objects dans cette methode
  def load_world
    print 'Chargement du monde... '
    
    # un cube
    geom = ODE::Box.new(1,1,1,@space) # n'oubliez pas @space, je changerai ca plus tard
    geom.position = [2,2,0]
    
    # ... et c'est tout ce qu'on peut faire aujourd'hui
    puts 'fini'
  end
  
end
