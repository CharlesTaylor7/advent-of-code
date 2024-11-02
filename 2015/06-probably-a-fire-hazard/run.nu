def dir [] {
  $env.CURRENT_FILE | path dirname
} 

def input [] {
  # "toggle 1,1 through 2,4\nturn off 2,2 through 3,3"
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
    let coords = $it | reject act | values | into int
    let new = match $coords {
      [ $x1 $y1 $x2 $y2 ] => { 
        build-record $acc $it.act $x1 $y1 $x2 $y2 
      }
    }
    $acc | merge $new
  }
}

def build-record [acc act x1 y1 x2 y2]: any -> record {
   seq $x1 $x2 
   | each { |x| 
     seq $y1 $y2 | each { |y| 
      let key = $"($x),($y)" 
      let value = match $act {
        "turn off" => { false }
        "turn on" => { true }
        "toggle" => { 
          $acc | get -i $key | default false | not $in
        }
      }
      [ $key $value ]
    }
  }
  | flatten
  | into record
      
}

def part2 [] {
}

