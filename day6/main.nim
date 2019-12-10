from strformat import fmt
from strutils import parseInt, split, join
from sequtils import map
import sugar

type
  Node = ref object
    val: string
    children: seq[ref Node]

proc getNode(forest: seq[ref Node], val: string): ref Node =
  for node in forest:
    if node == nil:
      continue
    elif node.val == val:
      return node
    else:
      var
        found: ref Node = nil
        i = 0
      while found == nil and i < node.children.len:
        found = getNode(@[node.children[i]], val, child)
      return found
  return nil

proc addEdge(forest: [ref Node], val: string, child: ref Node): void =
  for node in forest:
    if node == nil:
      continue
    elif node.val == val:
      node.children.add(child)
    else:
      var
        added: ref Node = nil
        i = 0
      while added == nil and i < node.children.len:
        added = addEdge(node.children[i], val, child)
  
      return nil
  
    return node
    

proc main() =
  var forest: Node
  try:
    var edge = stdin.readline().split(')')
    if tree == nil:
      new(tree)
      tree.val = edge[0]
    var child = tree.getNode(tree, edge[1])
    if child == nil:
      new(child)
      child.val = edge[1]
    if addEdge(tree, edge[0], child) == nil:
      raise newException(Exception, fmt"failed to add child")
  except EOFError:
    echo tree
    # return height(prog)
  
main()
