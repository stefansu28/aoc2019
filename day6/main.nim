from strformat import fmt
from strutils import parseInt, split, join
from sequtils import foldl
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

proc orbitChecksum(node: Node): int =
  if node.children.len == 0:
    return 0
  return node.children.foldl(a + orbitChecksum(b) + 1)

proc addEdge(nodes: var NodeList, val: string, child: string): void =
  var parent: Node
  for node in nodes:
    if node.val == val:
      parent = node

  if parent == nil:
    var (node, _) = nodes.getOrCreateNode(val)
    parent = node
  var (_, i) = nodes.getOrCreateNode(child)
  parent.children.add(i)

proc main() =
  var nodes: NodeList
  while not stdin.endOfFile():
    var edge: seq[string] = stdin.readline().split(')')
    nodes.addEdge(edge[0], edge[1])

  echo orbitChecksum(nodes[0])
  
main()
