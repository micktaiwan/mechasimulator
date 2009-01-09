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
    :rotate => 0
    }
  
}
