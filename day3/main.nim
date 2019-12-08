from strformat import fmt
from strutils import parseInt, split, join
from sequtils import map
import sugar

type
  Point = array[0..1, int]
  Segment = (Point, Point)
  Wire = seq[Segment]

proc dist(p: Point): int {.inline.}=
  return abs(p[0]) + abs(p[1])

# proc segMax(l: Segment): int {.inline.} =
#   return max(dist(l[0]), dist(l[1])

# proc segMin(l: Segment): int {.inline.} =
#   return min(dist(l[0]), dist(l[1])
  
proc intersect(l1: Segment, l2: Segment): (bool, Point) =
  # dir1 is the index that segment 1 changes
  # otherDir1 is the index that segment 1 is constant
  # same for 2's
  let
    dir1 = if l1[0][0] == l1[1][0]: 1 else: 0
    otherDir1 = (dir1 + 1) mod 2
    dir2 = if l2[0][0] == l2[1][0]: 1 else: 0
    otherDir2 = (dir2 + 1) mod 2

  # echo fmt"{l1}, {l2}"

  var p: Point
  # segments are going in different directions
  if dir1 != dir2:
    p[otherDir1] = l1[0][otherDir1]
    var
      minVal = min(l2[0][dir2], l2[1][dir2])
      maxVal = max(l2[0][dir2], l2[1][dir2])
    if not (p[otherDir1] in minVal..maxVal):
      # echo "1 false"
      return (false, p)

    p[otherDir2] = l2[0][otherDir2]
    minVal = min(l1[0][dir1], l1[1][dir1])
    maxVal = max(l1[0][dir1], l1[1][dir1])
    var intersected = p[otherDir2] in minVal..maxVal
    # echo fmt"2 {intersected}"
    return (intersected, p)

    # segments are going in same direction
  else:
    if l1[0][otherDir1] != l2[0][otherDir2]:
      return (false, p)
    p[otherDir1] = l1[0][otherDir1]
    let
      min1 = min(l1[0][dir1], l1[1][dir1])
      max1 = max(l1[0][dir1], l1[1][dir1])
      min2 = min(l2[0][dir2], l2[1][dir2])
      max2 = max(l2[0][dir2], l2[1][dir2])

    var possiblePoints: array[0..1, Point]
    if max1 < min2 or min1 > max2:
      # echo "3 false"
      return (false, p)
    if max1 in min2..max2:
       possiblePoints[0][otherDir1] = p[otherDir1]
       possiblePoints[0][dir1] = max1

       possiblePoints[1][otherDir1] = p[otherDir1]
       possiblePoints[1][dir1] = min2

    if min1 in min2..max2:
       possiblePoints[0][otherDir1] = p[otherDir1]
       possiblePoints[0][dir1] = min1

       possiblePoints[1][otherDir1] = p[otherDir1]
       possiblePoints[1][dir1] = max2
    if dist(possiblePoints[0]) < dist(possiblePoints[1]):
      p = possiblePoints[0]
    else:
      p = possiblePoints[1]
    # echo "4 true"
    return (true, p)

proc createWire(input: openarray[string]): Wire =
  var
    p: Point = [0,0]
    wire: Wire
    i:int = 0
  for s in input:
    var next = p
    var dir = input[i]
    i += 1
    case dir[0]
    of 'R':
      next[0] += parseInt(dir[1..^1])
    of 'L': next[0] -= parseInt(dir[1..^1])
    of 'U': next[1] += parseInt(dir[1..^1])
    of 'D': next[1] -= parseInt(dir[1..^1])
    else: raise newException(Exception, fmt"bad input {dir}")
    wire.add((p, next))
    p = next
  return wire

proc main() =
  var
    wire1 = stdin.readline().split(',').createWire()
    wire2 = stdin.readline().split(",").createWire()
    minInt = 0

  for s1 in wire1:
    for s2 in wire2:
      var (intersected, point) = intersect(s1, s2)
      if intersected and (dist(point) < minInt or minInt == 0):
        # echo fmt"s1: {s1} s2: {s2}"
        # echo fmt"point: {point} dist: {dist(point)}"
        minInt = dist(point)

  echo minInt

main()
