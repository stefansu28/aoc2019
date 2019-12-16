from strformat import fmt
from strutils import parseInt, split, join
from sequtils import map
import sugar
import tables

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
    AdjRelBase
    Halt = 99
  Op = tuple[inst: Inst, x: int, y: int, z: int]
  ParamMode = enum
    Position
    Immediate
    Relative
  Program = tuple[pc: int, mem: seq[int], relBase: int, extraMem: ref Table[int, int]]

proc jump(i: Inst): int =
  case i:
  of Add, Mult, Less, Eq: return 4
  of In, Out, AdjRelBase: return 2
  of Jt, Jf: return 3
  else: raise newException(Exception, fmt"no jump for instruction {i}")

proc jump(o: Op): int =
  return jump(o.inst)

proc readMem(mem: seq[int], extra: ref Table[int, int], address: int): int {.inline.} =
  if address < mem.len:
    return mem[address]
  if not extra.hasKey(address):
    extra[address] = 0
  return extra[address]

proc writeMem(mem: var seq[int], extra: ref Table[int, int], address: int, val: int): void {.inline.} =
  if address < mem.len:
    mem[address] = val
  extra[address] = val

proc readParam(mode: ParamMode, val: int, prog: Program): int =
  echo mode
  case mode:
  of Position: return readMem(prog.mem, prog.extraMem, val)
  of Immediate: return val
  of Relative:
    echo prog.relBase + val
    return readMem(prog.mem, prog.extraMem, prog.relBase + val)
  
proc parseInst(prog: Program): Op =
  var
    (pc, mem, _, _) = prog
    opCode = mem[pc]
    op: Op
    inst = Inst(opCode mod 100)
  op.inst = inst
  case inst:
  of Add, Mult,Jt..Eq:
    op.x = readParam(ParamMode((opCode div 100) mod 10), mem[pc + 1], prog)
    op.y = readParam(ParamMode((opCode div 1000) mod 10), mem[pc + 2], prog)
    op.z = mem[pc + 3]
  of In, Out, AdjRelBase: op.x = readParam(ParamMode((opCode div 100) mod 10), mem[pc + 1], prog)
  of Halt: discard
  # else: raise newException(Exception, fmt"TODO")

  return op

proc run(progmem: var seq[int], input: openarray[int]): (int, seq[int]) =
  var
    prog: Program = (0, progmem, 0, newTable[int, int]())
    read = 0
    output = newSeq[int](0)

  # echo map(prog, x => $x).join(",")
  while true:
    var op = parseInst(prog)
    echo op
    case op.inst:
    of Add: writeMem(prog.mem, prog.extraMem, op.z, op.x + op.y)
    of Mult: writeMem(prog.mem, prog.extraMem, op.z, op.x * op.y)
    of In:
      writeMem(prog.mem, prog.extraMem, op.x, input[read])
      read += 1
    of Out: output.add(op.x)
    of Jt:
      if op.x != 0:
        prog.pc = op.y - jump(op)
      else: discard
    of Jf:
      if op.x == 0:
        prog.pc = op.y - jump(op)
      else: discard
    of Less:
      var val = 0
      if op.x < op.y:
        val = 1
      writeMem(prog.mem, prog.extraMem, op.z, val)
    of Eq:
      var val = 0
      if op.x == op.y:
        val = 1
      writeMem(prog.mem, prog.extraMem, op.z, val)
    of AdjRelBase: prog.relBase += op.x
    of Halt: return (prog.pc, output)
    # else: raise newException(Exception, fmt"unknown inst {op}")
    prog.pc += jump(op)

proc main() =
  var
    prog = stdin.readline().split(',').map(x => x.parseInt())

  echo run(prog, [1])
  
main()
