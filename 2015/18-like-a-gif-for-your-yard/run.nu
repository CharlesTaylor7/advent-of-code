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
  seq 1 100
  | reduce --fold $map { |_ acc| conway $acc }
  | transpose 
  | get column1
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
          if $result == "#" { 1 } else { 0 }
        } 
      }
      | flatten
      | math sum
      let key = key $i $j
      let symbol = match ($record | get $key) {
        "#" if $n >= 2 and $n <= 3 => { "#" }
        "." if $n == 3 => { "#" }
        _ => { "." }
      }
      [$key  $symbol]
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

