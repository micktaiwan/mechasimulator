CONFIG = {
  
  :joy => { # joystick configuration
    :dev => '/dev/input/js0',
    :factor => (32000.0)
    },
  
  :log => { # log config (not used)
    :joy   => nil,
    :pos   => nil,
    :event => nil,
    :collision => nil,
    :camera => nil,
    :debug => nil
  },
  
  :mouse => {
    :speed_factor => 0.2
    },
  
  :draw => {
    :point_size  =>6,
    :constraints => true,
    :forces => true
    },
    
  :cam => {
    :follow => true,
    :rotate => 0    # distance of rotation, 0 = no rotation
    },
  
  :ps =>  { # particle system
    :speed_factor => 1, # no impact on FPS, 1 for normal, 10 for ten times slower, 0.5 for 2 times faster
    :nb_iter=> 1, # impact on FPS, greater means better simulation, but slower display
    :collisions => nil # nil or true 
    }
  
}
