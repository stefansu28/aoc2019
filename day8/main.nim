from strformat import fmt
from strutils import parseInt, split, join
from sequtils import map
import sugar

const
  Width = 25
  Height = 6
  LayerSize = Width * Height

type Layer = array[LayerSize, int8]

proc main() =
  var layers = newSeq[Layer]()

  while not stdin.endOfFile:
    var newLayer: Layer
    discard stdin.readBytes(newLayer, 0, LayerSize)
    for i in 0..<newLayer.len:
      newLayer[i] -= ord('0')
    layers.add(newLayer)
  
  var
    maxZeros = LayerSize
    maxVal = -1

  for layer in layers:
    var counts: array[0..2, int]
    for val in layer:
      counts[val] += 1
    if counts[0] < maxZeros:
      maxZeros = counts[0]
      maxVal = counts[1] * counts[2]

  echo maxVal
main()
