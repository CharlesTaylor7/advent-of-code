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
  split row "\n"
  | parse --regex '(?<act>toggle|turn on|turn off) (?<x1>\d+),(?<y1>\d+) through (?<x2>\d+),(?<y2>\d+)'
  | reduce --fold {} { |it acc|
    match $it {
      { act: $act x1: $x1 x2: $x2 y1: $y1 y2: $y2 } => {
        seq $x1 $x2 
        | each { |x| 
          seq $y1 $y2 | each { |y| 
            let key = $"($x),($y)"
            let value = match $act {
              "turn off" => { false }
              "turn on" => { true }
              "toggle" => { $acc | get $key | not }
            }
            [$key $value]
          }
        }
        | flatten
        | into record
      }
    }
  }
}

def part2 [] {
}

