let dir = $env.CURRENT_FILE | path dirname
let input = open ($dir | path join "input.txt")

def nu-complete-part [] {
  [1 2]
}

export def main [part: int@"nu-complete-part"] {
  match $part {
    1 => (part1)
    2 => (part2)
  }
}

def part1 [] {
}

def part2 [] {
}
