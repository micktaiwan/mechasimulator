# http://www.flipcode.com/archives/Basic_Collision_Detection.shtml

require 'vector'
require 'particle'
require 'util'

PLANE_FRONT     = 1
PLANE_BACK      = -1
PLANE_COINCIDE  = 0
NIL3 = [nil,nil,nil]

class Poly

  attr_accessor :particles

  # get 3 particles
  def initialize(arr_of_particles)
    @particles = arr_of_particles
    @p1 = @particles[0]
    @p2 = @particles[1]
    @p3 = @particles[2]
=begin    
    # verify that all points are in the plane
    return if @particles.size <= 3
    3.upto(@particles.size) { |i|
      raise "surface not plane" if not in?(@particles[i].current)      
      }
=end
  end

  def normal
    (@p1.current-@p2.current).cross(@p3.current-@p2.current)
  end
  
  def plane_distance
    # -n.p
    normal.inverse.dot(@p2.current)
  end

  def classify(dest)
    scalar = normal.dot(dest) + plane_distance
    return PLANE_FRONT if( scalar > 0.0 )
    return PLANE_BACK  if( scalar < 0.0 )
    return PLANE_COINCIDE
  end
  
  # return [distance to intersection, direction vector "ray"]
  # distance should awys be positive, except when there is no intersection with the place, we return -1
  def dist_inter(from, dest)
    ray = dest - from 
    denom = normal.dot(ray)
    return [-1,ray] if denom.abs < 0.000001 # no intersection, normal and ray are perpendicular
    t = -(normal.dot(from) + plane_distance )   / denom
    [t, ray]
  end
  
  # return [the point where the intersection occurs, distance, ray]
  def intersection(from, dest)
    dist, ray = dist_inter(from,dest) 
    [from + (ray * dist), dist, ray]
  end
  
  def angle(v1,v2)
    d = v1.normalize.dot(v2.normalize)
    if d > 0.99999
      d = 0.9999
    elsif d < -0.99999
      d = -0.9999
    end
    begin
      Math.acos(d)
    rescue Exception=>e
      puts d
      raise
    end
  end
  
  # determine if point is in the polygone
  # point must be in the polygone plane !
  def in?(point)
    # sum all the angles
    sum = 0
    @particles.each_index { |i|
      sum += angle((@particles[i].current - point), (@particles[i-1].current - point))
      }
    (sum-2*Math::PI).abs < 0.0000001
  end
  
  def collision?(p)
    return NIL3 if include?(p)
    from = p.old
    dest = p.current
    return NIL3 if classify(from) == classify(dest)
    point, distance, ray = intersection(from, dest)
    return NIL3 if not in?(point)
    [point, distance, ray]
  end
  
  def include?(p)
    @particles.include?(p)
  end
  
end

if __FILE__ == $0

p1 = Particle.new(0,0,0)
p2 = Particle.new(0,1,0)
p3 = Particle.new(1,0,0)
test = Particle.new(-1,0,0)
poly = Poly.new([p1, p2, p3])

from = MVector.new(1.7, 0.1, 1)
dest = MVector.new(0.1, 0.1, -1)

print "angle: ", poly.angle(test.current, p3.current).to_deg, "\n"
print "normale:  ", poly.normal, "\n"
print "from classif:  ", poly.classify(from), "\n"
print "dest classif:  ", poly.classify(dest), "\n"
print "distance: ", poly.dist_inter(from,dest).join(', '), "\n"
print "intersection point: ", poly.intersection(from,dest), "\n"
print "in: ", poly.in?(poly.intersection(from,dest)[0]), "\n"

end


