from strformat import fmt
from strutils import parseInt, split, join
from sequtils import map
import sugar

type
  Inst = enum
    Add = 1
    Mult
    In
    Out
    Jt
    Jf
    Less
    Eq
    Halt = 99
  # Op = object
  #   case inst: Inst
  #   of Add, Mult:
  #     x: int
  #     y: int
  #     output: int
  #   of In: nil
  #   of Out: address: int
  #   of Halt: nil
  Op = tuple[inst: Inst, x: int, y: int, z: int]
  ParamMode = enum
    Position
    Immediate
  ProgState = tuple[pc: int, prog: seq[int]]

proc jump(i: Inst): int =
  case i:
  of Add, Mult, Less, Eq: return 4
  of In, Out: return 2
  of Jt, Jf: return 3
  else: raise newException(Exception, fmt"no jump for instruction {i}")

proc jump(o: Op): int =
  return jump(o.inst)

proc readParam(mode: ParamMode, val: int, mem: seq[int]): int =
  case mode:
  of Position: return mem[val]
  of Immediate: return val
  
proc parseInst(pc: int, mem: seq[int]): Op =
  var
    opCode = mem[pc]
    op: Op
    inst = Inst(opCode mod 100)
  op.inst = inst
  case inst:
  of Add, Mult,Jt..Eq:
    op.x = readParam(ParamMode((opCode div 100) mod 10), mem[pc + 1], mem)
    op.y = readParam(ParamMode((opCode div 1000) mod 10), mem[pc + 2], mem)
    op.z = mem[pc + 3]
  of In, Out: op.x = mem[pc + 1]
  of Halt: discard
  # else: raise newException(Exception, fmt"TODO")

  return op

proc run(prog: var seq[int], input: openarray[int], pcStart:int): (int, seq[int]) =
  var
    pc = pcStart
    read = 0
    output = newSeq[int](0)

  # echo map(prog, x => $x).join(",")
  while true:
    var op = parseInst(pc, prog)
    # echo op
    case op.inst:
    of Add: prog[op.z] = op.x + op.y
    of Mult: prog[op.z] = op.x * op.y
    of In:
      prog[op.x] = input[read]
      read += 1
    of Out:
      # modified for day7 pt2
      # will "halt" until feedback amp is done
      output.add(prog[op.x])
      return (pc + jump(Out), output)
    of Jt:
      if op.x != 0:
        pc = op.y - jump(op)
      else: discard
    of Jf:
      if op.x == 0:
        pc = op.y - jump(op)
      else: discard
    of Less:
      if op.x < op.y:
        prog[op.z] = 1
      else: prog[op.z] = 0
    of Eq:
      if op.x == op.y:
        prog[op.z] = 1
      else: prog[op.z] = 0
    of Halt: return (pc, output)
    # else: raise newException(Exception, fmt"unknown inst {prog[pc]}")
    pc += jump(op)


const
  PermStart = 5
  PermutationLen = 5

proc genPhases(perms: var seq[seq[int]]): seq[seq[int]] =
  while perms[0].len < PermutationLen:
    var newPerms = newSeq[seq[int]]()
    for perm in perms:
      for x in PermStart..<(PermutationLen + PermStart):
        if not (x in perm):
          var newPerm = deepCopy(perm)
          newPerm.add(x)
          newPerms.add(newPerm)
    perms = newPerms
  return perms  


proc halted(state: ProgState): bool {.inline.} =
  return parseInst(state.pc, state.prog).inst == Halt

proc main() =
  var
    prog = stdin.readline().split(',').map(x => x.parseInt())
    phasePerms: seq[seq[int]] = newSeq[seq[int]](PermutationLen)
    maxOutput = 0

  discard genPhases(phasePerms)
  for phases in phasePerms:
    var
      output = 0
      progStates = newSeq[ProgState](phases.len)
      i = 0
    while progStates[^1].pc == 0 or not halted(progStates[^1]):
      var
        phase = phases[i]
        state = progStates[i]
        input = @[output]
      if state.prog.len == 0:
        state.prog = deepCopy(prog)
        state.pc = 0
        input = @[phase, output]
      # echo fmt"input: {input}, pc: {state.pc}"
      var progOutput = run(state.prog, input, state.pc)
      # echo i
      # echo progOutput
      # echo state.prog
      state.pc = progOutput[0]
      if progOutput[1].len > 0:
        output = progOutput[1][0]
      progStates[i] = state
      i = (i + 1) mod phases.len
    if output > maxOutput:
      maxOutput = output
  
  echo maxOutput
  
  
  
main()
