from strformat import fmt
from strutils import parseInt, split, join
from sequtils import map
import sugar

const mapSize = 64

type
  Point = array[0..1, int]
  Segment = (Point, Point, int)
  Wire = seq[Segment]
  StepMapEntry = object
    val: int
    p: Point
    next: ref StepMapEntry
  StepMap = array[mapSize, ref StepMapEntry]

proc hashPoint(p: Point): int =
  return (abs(p[0] + 7789*p[1])) mod mapSize

proc getSetMap(m: ptr StepMap, p: Point): (bool, int) =
  var
    prev: ref StepMapEntry = nil
    node = m[hashPoint(p)]
  while node != nil and node.p != p:
    prev = node
    node = node.next
  if node.p == p:
    return (true, node.val)
  else:
    return (false, 0)

proc setStepMap(m: ptr StepMap, p: Point, steps: int): int =
  var
    prev: ref StepMapEntry = nil
    node = m[hashPoint(p)]
  while node != nil and node.p != p:
    prev = node
    echo node == nil
    node = node.next
    echo "hi"
  if prev == nil and node == nil:
    var newNode: ref StepMapEntry
    new(newNode)
    newNode.val = steps
    newNode.p = p
    newNode.next = nil
    m[hashPoint(p)] = newNode
    return steps
  if node == nil:
    # echo prev == nil
    new(prev.next)
    prev.next.val = steps
    prev.next.p = p
    prev.next.next = nil
    return steps
  else:
    return node.val

proc dist(p: Point): int {.inline.}=
  return abs(p[0]) + abs(p[1])
  
proc intersect(l1: Segment, l2: Segment): (bool, Point, int) =
  # dir1 is the index that segment 1 changes
  # otherDir1 is the index that segment 1 is constant
  # same for 2's
  let
    dir1 = if l1[0][0] == l1[1][0]: 1 else: 0
    otherDir1 = (dir1 + 1) mod 2
    dir2 = if l2[0][0] == l2[1][0]: 1 else: 0
    otherDir2 = (dir2 + 1) mod 2

  # echo fmt"{l1}, {l2}"

  var
    p: Point
    steps: int
  # segments are going in different directions
  if dir1 != dir2:
    p[otherDir1] = l1[0][otherDir1]
    var
      minVal = min(l2[0][dir2], l2[1][dir2])
      maxVal = max(l2[0][dir2], l2[1][dir2])
    if not (p[otherDir1] in minVal..maxVal):
      # echo "1 false"
      return (false, p, steps)

    p[otherDir2] = l2[0][otherDir2]
    minVal = min(l1[0][dir1], l1[1][dir1])
    maxVal = max(l1[0][dir1], l1[1][dir1])
    var intersected = p[otherDir2] in minVal..maxVal
    # echo fmt"2 {intersected}"
    if intersected:
      steps = l1[2] + l2[2] + abs(p[dir1] - l1[0][dir1]) + abs(p[dir2] - l2[0][dir2])
      echo fmt"l1:: {l1}, l2: {l2}, p: {p} steps: {steps}"
    return (intersected, p, steps)

    # segments are going in same direction
  else:
    if l1[0][otherDir1] != l2[0][otherDir2]:
      return (false, p, steps)
    p[otherDir1] = l1[0][otherDir1]
    let
      min1 = min(l1[0][dir1], l1[1][dir1])
      max1 = max(l1[0][dir1], l1[1][dir1])
      min2 = min(l2[0][dir2], l2[1][dir2])
      max2 = max(l2[0][dir2], l2[1][dir2])

    var possiblePoints: array[0..1, Point]
    if max1 < min2 or min1 > max2:
      # echo "3 false"
      return (false, p, steps)
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
    steps = l1[2] + l2[2] + abs(p[dir1] - l1[0][dir1]) + abs(p[dir2] - l2[0][dir2])
    return (true, p, steps)

proc iterPoints(p1: Point, p2: Point, op: proc (p: Point): int{.closure, gcsafe, locks: 0.}
): void =
  var
    dir = if p1[0] == p2[0]: 1 else: 0
    p = p1
  discard op(p)
  while p != p2:
    p[dir] += 1
    discard op(p)

proc createWire(input: openarray[string]): Wire =
  var
    p: Point = [0,0]
    wire: Wire
    i:int = 0
    cumStep = 0
    stepMap: StepMap

  proc addPoint(p: Point): int =
    setStepMap(addr(stepMap), p, cumStep)
  for s in input:
    var
      next = p
      dir = input[i]
      step: int
    i += 1
    case dir[0]
    of 'R':
      next[0] += parseInt(dir[1..^1])
      step = next[0]
    of 'L':
      next[0] -= parseInt(dir[1..^1])
      step = next[0]
    of 'U':
      next[1] += parseInt(dir[1..^1])
      step = next[1]
    of 'D':
      next[1] -= parseInt(dir[1..^1])
      step = next[1]
    else: raise newException(Exception, fmt"bad input {dir}")
    iterPoints(p, next, addPoint)
    var (_, pointStep) = getSetMap(addr(stepMap), p)
    wire.add((p, next, pointStep))
    cumStep += abs(step)
    p = next
  return wire

proc main() =
  var
    wire1 = stdin.readline().split(',').createWire()
    wire2 = stdin.readline().split(",").createWire()
    minInt = 0

  for s1 in wire1:
    for s2 in wire2:
      var (intersected, point, steps) = intersect(s1, s2)
      if intersected and (steps < minInt or minInt == 0):
        # echo fmt"s1: {s1} s2: {s2}"
        # echo fmt"point: {point} dist: {dist(point)}"
        minInt = steps

  echo minInt

main()
