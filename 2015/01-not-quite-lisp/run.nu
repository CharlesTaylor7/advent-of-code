export def part1 [] {
  let dir = $env.CURRENT_FILE | path dirname
  let input = open ($dir | path join "input.txt")

  let total = $input | str length
  let down = $input
  | split chars 
  | where { $in == ")" }
  | length

  print ($total - 2 * $down)
}

export def part2 [] {
  let dir = $env.CURRENT_FILE | path dirname
  let input = open ($dir | path join "input.txt")

  mut tally = 0

  for p in ($input | split chars | enumerate ) {
    if $p.item == "(" {
      $tally = $tally + 1
    } else if $p.item == ")" {
      $tally = $tally - 1
      if $tally < 0 {
        return ($p.index + 1)
      }
    } else {
      make error {
        msg: $"unexpected char: ($p)"
      }
    }
  }
}
