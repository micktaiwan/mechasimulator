CONFIG = {
  
  :joy => { # joystick configuration
    :dev => '/dev/input/js0',
    :axe1x => 0,
    :axe1y => 1,
    :axe2x => 3,
    :axe2y => 2 
  },
  
  :sleep => 0.01, # sleep time
  
  :log => { # log config
    :joy   => nil,
    :pos   => nil,
    :event => nil,
    :collision => true
  }
  
}
