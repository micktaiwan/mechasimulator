CONFIG = {
  
  :joy => { # joystick configuration
    :dev => '/dev/input/js0',
    :factor => (32000.0/16),
    :axe1x => 0,
    :axe1y => 1,
    :axe2x => 3,
    :axe2y => 2 
  },
  
  :sleep => 0.01, # sleep time
  
  :log => { # log config
    :joy   => nil,
    :pos   => true,
    :event => nil,
    :collision => nil
  }
  
}
