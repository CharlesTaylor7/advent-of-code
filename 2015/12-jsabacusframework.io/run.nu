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

export def part1 [] {
  from json | sum 1
}

export def part2 [] {
  from json | sum 2
}


export def sum [part: int]: any -> int {
  let val = $in
  match ($val | get-type) {
    'int' => { $val }
    'string' => { 0 }
    'record' => { $val | sum-record $part }
    'list' | 'table' => { $val | sum-list $part }
    $t => { print $t}
  }
}

export def get-type []: any -> string {
  describe | split row '<' | first
}

export def sum-record [part: int]: record -> int {
  let vals = transpose key val | get val 
  if $part == 2 and ($vals | any { $in == "red" }) {
    0
  } else {
    $vals | sum-list $part
  }
}

export def sum-list [part: int]: list -> int {
  each { sum $part } | math sum
}

