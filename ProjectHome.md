# Mecha Simulator #

The goal to this project is to be able to build objects (ultimately robots or any mechanic device) in a simulated 3D physic world, then to be able to control them with a joystick.

Programming language is [Ruby](http://ruby-lang.org).

**Screenshots**

```
# define a necklace:
object
  20.times do |i|
    p(0,0.1+i*0.1,2)
    string :last_two # do nothing if no two last elements
  end
  fix   :first
end_object

gravity :all
```

result:

![http://faivrem.googlepages.com/mecha_necklace.png](http://faivrem.googlepages.com/mecha_necklace.png)

```
# a box fixed by 2 points
object
  p(0,0,2)
  p(1,0,2)
  p(1,2,2)
  p(0,2,2)

  fix p(0,0,2.5)
  fix p(1,0,2.5)
  p(1,2,2.5)
  p(0,2,2.5)

  string 0,4
  string 1,5
  string 2,6
  string 3,7

  string 0,1
  string 1,2
  string 2,3
  string 3,0

  string 4,5
  string 5,6
  string 6,7
  string 7,4

  string 0,6
  string 1,7
  string 2,4
  string 3,5
end_object

boundary :all, :z, :>, 0
gravity  :all
```

result:

![http://faivrem.googlepages.com/mecha_box.png](http://faivrem.googlepages.com/mecha_box.png)


## Installation ##

This is a really simple list of steps, if you need detailled explanation, just contact me (see below).

  * install Ruby `sudo apt-get install ruby1.8`
  * install rubygems
  * install ruby-opengl

then
  * svn checkout http://mechasimulator.googlecode.com/svn/trunk/ mechasimulator
  * run 'ruby main.rb' in the mechasimulator folder

define objects in the objects.rb file

## Contact ##

faivrem at gmail dot com (also on gtalk)