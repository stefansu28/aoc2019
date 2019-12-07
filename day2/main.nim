from strformat import fmt
from strutils import parseInt, split, join
from sequtils import map
import sugar

type Input = (int, int)

proc run(prog: var seq[int], input: Input): int64 =
  var
    pc = 0
    

  prog[1] = input[0]
  prog[2] = input[1]
  # echo map(prog, x => $x).join(",")
    
  while true:
    case prog[pc]
    of 1:
      let
        x = prog[prog[pc+1]]
        y = prog[prog[pc+2]]
      prog[prog[pc+3]] = x + y
      pc += 4
    of 2:
      let
        x = prog[prog[pc+1]]
        y = prog[prog[pc+2]]
      prog[prog[pc+3]] = x * y
      pc += 4
    of 99:
      return prog[0]
    else:
      raise newException(Exception, fmt"uknown inst {prog[pc]}")


proc main() =
  var prog = stdin.readline().split(',').map(x => x.parseInt())

  for x in 0..<100:
    for y in 0..<100:
      try:
        var copy: seq[int]
        deepCopy(copy, prog)
        let res = run(copy, (x,y))
        if res == 19690720:
          echo 100 * x + y
        # echo x, y, res
      except:
        discard 1 + 1
  
main()
