# http://www.flipcode.com/archives/Basic_Collision_Detection.shtml

require 'vector'
require 'particle'
require 'util'

PLANE_FRONT     = 1
PLANE_BACK      = -1
PLANE_COINCIDE  = 0
NIL4 = [nil, nil, nil, nil]

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

  def normal(pos)
    (@p1.send(pos)-@p2.send(pos)).cross(@p3.send(pos)-@p2.send(pos))
  end
  
  def plane_distance(pos)
    # -n.p
    normal(pos).inverse.dot(@p2.send(pos))
  end

  def classify(dest,pos)
    scalar = normal(pos).dot(dest) + plane_distance(pos)
    return PLANE_FRONT if( scalar > 0.0 )
    return PLANE_BACK  if( scalar < 0.0 )
    return PLANE_COINCIDE
  end
  
  # return [distance to intersection, direction vector "ray"]
  # distance should awys be positive, except when there is no intersection with the place, we return -1
  def dist_inter_current(from, dest)
    ray = dest - from 
    denom = normal(:current).dot(ray)
    return [-1,ray] if denom.abs < 0.000001 # no intersection, normal and ray are perpendicular
    t = -(normal(:current).dot(from) + plane_distance(:current) )   / denom
    [t, ray]
  end

  
  def ray_poly
    sum = @particles.inject(MVector.new(0,0,0)) { |sum,p| 
      sum += (p.current - p.old)
      }
    sum /= @particles.size    
  end
  
  def make_poly(ray)
    arr = @particles.map { |p| 
      v = p.old+ray
      Particle.new(v.x,v.y,v.z)
      }
    Poly.new(arr)
  end
  
  # return [distance to intersection, direction vector "ray"]
  # distance should awys be positive, except when there is no intersection with the place, we return -1
  def dist_inter_poly(point)
    ray = ray_poly 
    denom = normal(:current).dot(ray)
    return [-1,ray] if denom.abs < 0.000001 # no intersection, normal and ray are perpendicular
    t = -(normal(:current).dot(point) + plane_distance(:current) )   / denom
    [t, ray]
  end

  
  # return [the point where the intersection occurs, distance, ray]
  def intersection_point(from, dest)
    dist, ray = dist_inter_current(from,dest) 
    [from + (ray * dist), dist, ray]
  end

  # return [the point where the intersection occurs, distance, ray]
  def intersection_poly(point)
    dist, ray = dist_inter_poly(point) 
    poly = make_poly(ray*dist)
    [poly, dist, ray]
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
  def in?(point,pos)
    # sum all the angles
    sum = 0
    @particles.each_index { |i|
      sum += angle((@particles[i].send(pos) - point), (@particles[i-1].send(pos) - point))
      }
    (sum-2*Math::PI).abs < 0.0000001
  end
    
  def collision?(p)
    return NIL4 if include?(p)
    from = p.old
    dest = p.current
    if (classify(from,:current) != classify(dest,:current))
      point, distance, ray = intersection_point(from, dest)
      return NIL4 if not in?(point,:current)
      return [:particle, point, distance, ray]
    elsif (classify(dest,:current) != classify(dest,:old))
      poly, distance, ray = intersection_poly(dest)
      puts poly
      return NIL4 if not poly.in?(point,:current)
      return [:poly, point, distance, ray]
    end
    return NIL4
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


