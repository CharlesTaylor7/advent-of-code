def dir [] {
  $env.CURRENT_FILE | path dirname
} 

def input [] {
  open (dir | path join "input.txt")
}

def nu-complete-part [] {
  [1 2]
}

export def main [part: int@"nu-complete-part"] {
  match $part {
    1 => (input | part1)
    2 => (input | part2)
  }
}

def part1 [] {
  seq 1 40
  | reduce --fold $in { |_ acc| $acc | see-say }
  | str length
}

def part2 [] {
}

export def see-say [] {
  split chars
  | reduce --fold { str: "" count: null item: null } { |it acc|
    if $it == $acc.item {
      $acc | update count { $in + 1 }
    } else {
      {
        str: $"($acc.str)($acc.count)($acc.item)"
        count: 1
        item: $it
      }
    }
  } 
  | match $in {
      { $str $count $item } => {
        $"($str)($count)($item)"
      }
  }
  | tee { print $in }
}
