class MVector

  attr_accessor :x,:y,:z

  def initialize(x=0,y=0,z=0)
      @x,@y,@z = x,y,z
  end

  def reset
    @x, @y, @z = 0, 0, 0
  end

  # helpers methods
  def component_set(component,value)
    send("#{component}=", value)
  end

  def component_value(component)
    send("#{component}")
  end

  def ==(v)
    @x==v.x and @y==v.y and @z==v.z
  end

  def from_a(arr)
    @x, @y, @z = arr[0],arr[1],arr[2]
    self
  end

  def to_a
    [@x, @y, @z]
  end

  def to_s
    "|%s|" % [@x,@y,@z].join(', ')
  end

  def -(v)
    MVector.new(@x-v.x,@y-v.y,@z-v.z)
  end

  def inverse
    MVector.new(-@x,-@y,-@z)
  end


  def +(v)
    MVector.new(@x+v.x,@y+v.y,@z+v.z)
  end

  def *( scalar )
    MVector.new(@x*scalar,@y*scalar,@z*scalar)
  end

  def /( scalar )
    MVector.new(@x/scalar,@y/scalar,@z/scalar)
  end

  # Normalizes the vector in place.
  def normalize!
    l = length
    raise "vector lenght is 0" if l == 0
    @x /= l
    @y /= l
    @z /= l
    self
  end

  # Normalizes the vector in place.
  def normalize
    l = length
    l = 0.00001 if l == 0
    MVector.new(@x/l, @y/l, @z/l)
  end

  # Returns the magnitude of the vector, measured in the Euclidean norm.
  def length
    Math.sqrt( self.sqr )
  end

  # Returns the dot product of the vector with itself, which is also the
  # squared length of the vector, as measured in the Euclidean norm.
  def sqr
    self.dot( self )
  end

  # Return the dot-product
  def dot(v)
    scalar = 0.0
    scalar += @x*v.x
    scalar += @y*v.y
    scalar += @z*v.z
    return scalar
  end

  def cross(v)
    # (a2b3 - a3b2, a3b1 - a1b3, a1b2 - a2b1)
    MVector.new(@y*v.z - @z*v.y, @z*v.x - @x*v.z, @x*v.y - @y*v.x)
  end


end
