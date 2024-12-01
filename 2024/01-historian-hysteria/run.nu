export def input [] {
  $env.CURRENT_FILE 
  | path dirname
  | path join "input.txt"
  | open $in
}

def nu-complete-part [] {
  [1 2]
}

export def main [part: int@"nu-complete-part"] {
  input 
  | match $part {
    1 => part1
    2 => part2
  }
}

def part1 [] {
  let rows = split row "\n"
  | each { split row -r '\s+' | into int }

  let left = $rows | each { get 0 } | sort
  let right = $rows | each { get 1 } | sort
  $left | zip $right | each { ($in.0 - $in.1) | math abs } | math sum
}

def part2 [] {
  let rows = split row "\n"
  | each { split row -r '\s+' | into int }

  let left = $rows | each { get 0 } 
  let right = $rows | each { get 1 }

  $left 
  | each { |l|
    let n = $right | filter { |r| $l == $r } | length 
    $n * $l
  }
  | math sum
}
