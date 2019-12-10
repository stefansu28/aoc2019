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

proc jump(i: Inst): int =
  case i:
  of Add..Mult: return 4
  of In..Out: return 2
  else: raise newException(Exception, fmt"no jump for instruction {i}")

proc jump(o: Op): int =
  return jump(o.inst)

proc readParam(mode: ParamMode, val: int, mem: var seq[int]): int =
  case mode:
  of Position: return mem[val]
  of Immediate: return val
  
proc parseInst(pc: int, mem: var seq[int]): Op =
  var
    opCode = mem[pc]
    op: Op
    inst = Inst(opCode mod 100)
  op.inst = inst
  case inst:
  of Add, Mult:
    op.x = readParam(ParamMode((opCode div 100) mod 10), mem[pc + 1], mem)
    op.y = readParam(ParamMode((opCode div 1000) mod 10), mem[pc + 2], mem)
    op.z = mem[pc + 3]
  of In, Out: op.x = mem[pc + 1]
  of Halt: discard
  # else: raise newException(Exception, fmt"TODO")

  return op

proc run(prog: var seq[int]): int =
  var pc = 0

  # echo map(prog, x => $x).join(",")
  while true:
    var op = parseInst(pc, prog)
    # echo op
    case op.inst:
    of Add: prog[op.z] = op.x + op.y
    of Mult: prog[op.z] = op.x * op.y
    of In: prog[op.x] = stdin.readline().parseInt()
    of Out: echo prog[op.x]
    of Halt: return prog[0]
    # else: raise newException(Exception, fmt"unknown inst {prog[pc]}")
    pc += jump(op)


proc main() =
  var prog = stdin.readline().split(',').map(x => x.parseInt())
  discard run(prog)
  # echo prog
  
main()
