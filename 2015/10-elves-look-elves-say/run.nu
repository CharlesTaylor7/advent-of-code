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
  repeat 40 | str length
}

# https://www.youtube.com/watch?v=ea7lJkEhytA
# 92 elements...
def part2 [] {
  repeat 50 | str length
}

export def repeat [n: int] {
  let seed = $in
  seq 1 $n
  | reduce --fold $seed { |_ acc| ($acc | see-say) }
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
