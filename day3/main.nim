from strformat import fmt
from strutils import parseInt, split, join
from sequtils import map
import sugar

type
  Point = tuple[x: int, y: int]
  Segment = (Point, Point)
  Wire = seq[Segment]
  Dir = enum
    vert
    hor


proc dist(p: Point): int {.inline.}=
  return abs(p.x) + abs(p.y)

proc segMax(l: Segment): int {.inline.} =
  return max(dist(l[0]), dist(l[1])

proc segMin(l: Segment): int {.inline.} =
  return min(dist(l[0]), dist(l[1])
  
proc intersect(l1: Segment, l2: Segment): int =
  let
    dir: Dir = if l1[0].x == l1[1].x: vert else hor
    otherDir: Dir = if l2[0].x == l2[1].x: vert else hor
    index = if hor: 0 else 1
    otherIndex = (index + 1) mod 2

  var p: Point
  if dir != otherDir:
    p[index] = l1[index]
    p[otherIndex] = l2[otherIndex]




  
      

proc createWire(input: openarray[string]): Wire =
  var
    p: Point = (0,0)
    wire: Wire
    i:int = 0
  for s in input:
    # wire.add((p, p))
    var next = p
    var dir = input[i]
    i += 1
    case dir[0]
    of 'R': next.x += parseInt(dir[1..^1])
    of 'L': next.x -= parseInt(dir[1..^1])
    of 'U': next.y += parseInt(dir[1..^1])
    of 'D': next.y -= parseInt(dir[1..^1])
    else: raise newException(Exception, fmt"bad input {dir}")

    wire.add((p, next))
    p = next
  return wire

# proc run(wire1: ptr Segment, wire2: ptr Segment): int =
  
proc main() =
  var
    wire1 = stdin.readline().split(',').createWire()
    wire2 = stdin.readline().split(",").createWire()
    minInt = -1

  for s1 in wire1:
    for s2 in wire2:
      point = interset(s1, s2)
      if point > 0 and (point < minInt or minInt < 0):
        minInt = point

  echo minInt

main()
