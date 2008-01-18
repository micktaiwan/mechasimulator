CONFIG = {
  
  :joy => { # joystick configuration
    :dev => '/dev/input/js0',
    :factor => (32000.0/16),
    :control => 'camera', # 'robot' or 'camera'
    :axe1x => 0,
    :axe1y => 1,
    :axe2x => 3,
    :axe2y => 2 
  },
  
  :sleep => 0.04, # sleep time
  
  :log => { # log config
    :joy   => nil,
    :pos   => nil,
    :event => nil,
    :collision => nil,
    :camera => nil
  }
  
}
