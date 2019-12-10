from strformat import fmt
from strutils import parseInt, split, join
from sequtils import map
import sugar

const PassLen = 6

type PassArray = array[PassLen, int]

proc intToPass(input: int, p: ptr PassArray): void =
  var
    x = input
    i = 0
    m = 10
  while i < PassLen:
    p[i] = x mod m
    x = x div 10
    i += 1

proc passToInt(p: ptr PassArray): int =
  var
    acc = 0
    place = 1
  for x in p[]:
    acc += x*place
    place *= 10
  return acc

# proc fullPass(p: CompactPass): int {.inline.} =
#   return p[0] * 11 + p[1] * 1100 + p[2] * 110000

proc incPass(p: ptr PassArray): void =
  var inc = 1
  for i in 0..<p[].len:
    p[i] += inc
    if p[i] == 10:
      p[i] = 0
    else:
      return
  raise newException(Exception, "overflow")

proc checkPass(p: ptr PassArray): bool =
  var
    double = false
    prev = 10
  for x in p[]:
    if x > prev:
      return false
    double = double or (x == prev)
    prev = x

  return double


proc countPasswords(low: int, high: int): int =
  var
    pass: PassArray
    count = 0

  

  echo fmt"low: {low} high: {high}"
  intToPass(low, addr(pass))
  echo fmt"initial pass: {pass} passToInt: {addr(pass).passToInt()}"

  while addr(pass).passToInt() < high:
    if checkPass(addr(pass)):
      count += 1
      # echo addr(pass).passToInt()
    addr(pass).incPass()

  return count

proc main() =
  var
    input = stdin.readline().split("-")
    low = parseInt(input[0])
    high = parseInt(input[1])

  echo countPasswords(low, high)

main()
