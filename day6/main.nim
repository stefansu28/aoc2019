from strformat import fmt
from strutils import parseInt, split, join
from sequtils import map, foldl
import sugar

type
  Node = ref object
    val: string
    edges: seq[int]
  NodeList = seq[Node]

proc addNode(nodes: var NodeList, val: string): (Node, int) {.inline.} =
  var newNode: Node
  new(newNode)
  newNode.val = val
  nodes.add(newNode)
  return (newNode, nodes.len - 1)
  
proc getOrCreateNode(nodes: var NodeList, val: string): (Node, int) =
  for i in 0..<nodes.len:
    if nodes[i].val == val:
      return (nodes[i], i)
  return nodes.addNode(val)


# proc dijkstras(nodes: NodeList): seq[int] =
#   var
#     n = nodes.len
#     dist = newSeq[int](n)

#   return dist

proc findRoot(nodes: NodeList, i: int): int =
  for j in 0..<nodes.len:
    if i in nodes[j].edges:
      return findRoot(nodes, j)
  return i


proc paths(nodes: NodeList, i: int, depth: int): int =
  var
    node = nodes[i]
  return node.edges.map(n => paths(nodes, n, depth + 1)).foldl(a + b, 0) + depth
  
proc orbitChecksum(nodes: NodeList): int =
  var
    paths = paths(nodes, findRoot(nodes, 0), 0)
  return paths
  # return paths.foldl(a + b)
  # return node.edges.foldl(a + orbitChecksum(b) + 1)

proc addEdge(nodes: var NodeList, val: string, otherVal: string): void =
  var parent: Node
  for node in nodes:
    if node.val == val:
      parent = node

  if parent == nil:
    var (node, _) = nodes.addNode(val)
    parent = node
  var (_, i) = nodes.getOrCreateNode(otherVal)
  parent.edges.add(i)

proc echoTree(nodes: NodeList, i: int, indent: string): void =
  echo indent, nodes[i].val
  for adj in nodes[i].edges:
    echoTree(nodes, adj, indent & "| ")

proc pt1() =
  var nodes: NodeList
  while not stdin.endOfFile():
    var edge: seq[string] = stdin.readline().split(')')
    nodes.addEdge(edge[0], edge[1])

  # nodes.echoTree(findRoot(nodes, 0), " ")
  # echo nodes.map(n => n[])
  echo orbitChecksum(nodes)

proc findRoot2(nodes: NodeList, i: int): int =
  if nodes[i].edges.len == 0:
    return i
  else:
    return nodes.findRoot2(nodes[i].edges[0])

proc findDesc(nodes: NodeList, i, desc: int): int =
  if i == desc:
     return 0
  for child in nodes[i].edges:
    var levels = findDesc(nodes, child, desc)
    if levels >= 0:
      return levels + 1
  return -1

proc jumps(nodes: NodeList, i, you, san: int): int =
  var
    yourAnc = findDesc(nodes, i, you)
    sansAnc = findDesc(nodes, i, san)
  # echo fmt"{i}: {yourAnc}, {sansAnc}"
  if yourAnc < 0 or sansAnc < 0:
    return -1
  else:
    for child in nodes[i].edges:
      var cjumps = jumps(nodes, child, you, san)
      if cjumps > -1:
        return cjumps
    return yourAnc + sansAnc

proc pt2() =
  var nodes: NodeList
  while not stdin.endOfFile():
    var edge: seq[string] = stdin.readline().split(')')
    nodes.addEdge(edge[0], edge[1])

  # nodes.echoTree(findRoot(nodes, 0), " ")
  echo nodes.map(n => n[])
  var
    you: int
    san: int
    root = nodes.findRoot(0)
  for i in 0..<nodes.len:
    var node = nodes[i]
    if node.val == "YOU":
      you = i
    elif node.val == "SAN":
      san = i
    
  echo fmt"Root: {root}, You: {you}, San {san}"
  echo jumps(nodes, root, you, san) - 2
  # echo findDesc(nodes, 2, san)

# pt1()
pt2()
