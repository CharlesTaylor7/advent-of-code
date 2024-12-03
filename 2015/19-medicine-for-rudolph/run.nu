export def input [] {
  $env.CURRENT_FILE 
  | path dirname
  | path join "input.txt"
  | open $in
}

def nu-complete-part [] {
  [1 2]
}

def main [part: int@"nu-complete-part"] {
  input | match $part {
    1 => (part1)
    2 => (part2)
  }
}

export def part1 [] {

}

export def part2 [] {
}
