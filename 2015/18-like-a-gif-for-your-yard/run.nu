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
  let map = $in 
  | split row "\n"
  | enumerate
  | each { 
    let j = $in.index
    $in.item
    | split chars
    | enumerate 
    | each {
      let i = $in.index
      [(key $i $j) $in.item]
    }
  }
  | flatten
  | into record
  print $map
  conway $map
  # seq 1 100
  # | reduce --fold $map { |_ acc| conway ($acc | tee { print $in }) }
}

def conway [record]: nothing -> record {
  seq 0 99
  | each { |i|
    seq 0 99 
    | each { |j|
      let n = seq -1 1 
      | each { |k| 
        seq -1 1 
        | each { |l| 
          let result = $record | get -i (key ($i - $k) ($j - $l))
          if $result == "#" { return 1 }
        } 
      }
      | flatten
      | math sum

      [(key $i $j) $n]
    }
  }
  | flatten
  | into record
}

def key [i: int, j: int]: nothing -> string {
  $"($i)-($j)"
}

def part2 [] {
}

