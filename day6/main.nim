from strformat import fmt
from strutils import parseInt, split, join
from sequtils import map, foldl
import sugar

type
  Node = ref object
    val: string
    children: seq[int]
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
    if i in nodes[j].children:
      return findRoot(nodes, j)
  return i


proc paths(nodes: NodeList, i: int, depth: int): int =
  var
    node = nodes[i]
  return node.children.map(n => paths(nodes, n, depth + 1)).foldl(a + b, 0) + depth
  
proc orbitChecksum(nodes: NodeList): int =
  var
    sum = 0
    paths = paths(nodes, findRoot(nodes, 0), 0)
  return paths
  # return paths.foldl(a + b)
  # return node.children.foldl(a + orbitChecksum(b) + 1)

proc addEdge(nodes: var NodeList, val: string, child: string): void =
  var parent: Node
  for node in nodes:
    if node.val == val:
      parent = node

  if parent == nil:
    var (node, _) = nodes.addNode(val)
    parent = node
  var (_, i) = nodes.getOrCreateNode(child)
  parent.children.add(i)

proc echoTree(nodes: NodeList, i: int, indent: string): void =
  echo indent, nodes[i].val
  for child in nodes[i].children:
    echoTree(nodes, child, indent & "| ")

proc main() =
  var nodes: NodeList
  while not stdin.endOfFile():
    var edge: seq[string] = stdin.readline().split(')')
    nodes.addEdge(edge[0], edge[1])

  # nodes.echoTree(findRoot(nodes, 0), " ")
  # echo nodes.map(n => n[])
  echo orbitChecksum(nodes)
  
main()
