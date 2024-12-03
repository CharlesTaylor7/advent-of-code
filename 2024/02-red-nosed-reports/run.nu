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
  split row "\n"
  | filter { split words | into int | is-safe-1 }
  | length
}

export def part2 [] {
  split row "\n" 
  | filter { split words | into int | is-safe-2 }
  | length
}

def is-safe-1 [] {
  let differences = window 2 | each { $in.0 - $in.1 } | collect
  ($differences | all { $in in [1 2 3] }) or ($differences | all { $in in [-1 -2 -3] })
}

export def is-safe-2 [] {
  let nums = $in
  if ($nums | is-safe-1) { return true }
  let n = $nums | length
  
  seq 0 ($n - 1)
  | any { |k| $nums | without $k | is-safe-1 }
}

export def without [k: int]: list<any> -> list<any> {
  ($in | take $k) ++ ($in | skip ($k + 1))
}
