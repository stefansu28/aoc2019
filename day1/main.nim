from strutils import parseInt

proc fuel(x: int64): int64 =
  var y = int64((x /% 3) - 2)
  if x <= 0:
    return 0
  return fuel(y) + max(y, 0)

proc main(): void =
  var
    sum: int64 = 0
    mass = 0
  try:
    while true:
      mass = stdin.readline().parseInt()
      sum += fuel(mass)
  except EOFError:
    echo sum
    return
  echo sum

main()
