from strformat import fmt
from strutils import parseInt, split, join
from sequtils import map
import sugar

const
  Width = 25
  Height = 6
  LayerSize = Width * Height

type
  Layer = array[LayerSize, int8]
  Color = enum
    Black = 0
    White
    Trans


proc readLayers(layers: var seq[Layer]): void =
  while not stdin.endOfFile:
    var newLayer: Layer
    discard stdin.readBytes(newLayer, 0, LayerSize)
    for i in 0..<newLayer.len:
      newLayer[i] -= ord('0')
    layers.add(newLayer)

proc pt1() =
  var layers = newSeq[Layer]()
  readLayers(layers)
  
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


proc printLayer(layer: Layer): void =
  for row in 0..<Height:
    for col in 0..<Width:
      var val = layer[col + row * Width]
      if val == 1:
        stdout.write(val)
      else:
        stdout.write ' '
    stdout.write('\n')
  
proc pt2() =
  var
    layers = newSeq[Layer]()
    image: Layer
  readLayers(layers)
  # initialize the image to be all transparent
  for i in 0..<image.len:
    image[i] = int8(Trans)

  for layer in layers:
    for i in 0..<LayerSize:
      if image[i] == int8(Trans) and layer[i] != int8(Trans):
         image[i] = layer[i]

  # for i in 0..<layers.len:
  #   echo fmt"i:"
  #   printLayer(layers[i])

  echo "image:"
  printLayer(image)

# pt1()
pt2()

