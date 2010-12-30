require 'vector'

SOUNDS = {:dead => 'dead.wav',
          :flying => 'flying.wav'}

def distance(a,b,x,y)
    Math.sqrt( (((x-a)*(x-a)) + ((y-b)*(y-b))).abs )
end

# thanks to http://alienryderflex.com/intersect/
def get_intersection(ax,ay, bx,by, cx,cy, dx,dy)

  #  Fail if either line segment is zero-length.
  return nil if ((ax==bx and ay==by) or (cx==dx and cy==dy))

  #  Fail if the segments share an end-point.
  return nil if (ax==cx and ay==cy or bx==cx and by==cy or  ax==dx and ay==dy or bx==dx and by==dy)

  #  (1) Translate the system so that point A is on the origin.
  bx -= ax; by -= ay
  cx -= ax; cy -= ay
  dx -= ax; dy -= ay

  #  Discover the length of segment A-B.
  distAB = Math.sqrt(bx*bx + by*by)

  #  (2) Rotate the system so that point B is on the positive X axis.
  theCos  = bx/distAB
  theSin  = by/distAB
  newX    = cx*theCos+cy*theSin
  cy      = cy*theCos-cx*theSin
  cx      = newX
  newX    = dx*theCos+dy*theSin
  dy      = dy*theCos-dx*theSin
  dx      = newX

  #  Fail if segment C-D doesn't cross line A-B.
  return nil if (cy<0 and dy<0) or (cy>=0 and dy>=0)

  #  (3) Discover the position of the intersection point along line A-B.
  abpos = dx + (cx-dx)*dy/(dy-cy)

  #  Fail if segment C-D crosses line A-B outside of segment A-B.
  return nil if (abpos < 0 or abpos > distAB)

  #  (4) Apply the discovered position to line A-B in the original coordinate system.
  x = ax + abpos*theCos
  y = ay + abpos*theSin

  #  Success
  return MVector.new(x,y,0)
end


