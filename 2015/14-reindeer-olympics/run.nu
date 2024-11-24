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
const regex = '(?<name>\w+) can fly (?<speed>\d+) km\/s for (?<duration>\d+) seconds, but then must rest for (?<rest>\d+) seconds\.'
export def part1 [] {
  parse-reindeer
  | sort-by -r avg-speed
  | first
  | distance 2503
}


export def part2 [] {
  let reindeer = $in | parse-reindeer
  const time = 2503
  seq 1 $time
  | each { |s|
    let traveled = $reindeer 
    | each { |row| { name: $row.name, traveled: ($row | distance $s)} }
    | sort-by -r traveled 
    let max = $traveled | get traveled | math max
    $traveled | take while { $in.traveled == $max } | get name
  }
  | flatten
  | uniq -c
  | get count
  | math max
}

def parse-reindeer [] {
  parse -r $regex
  | each { |row| 
    let s = $row.speed | into int
    let d = $row.duration | into int
    let r = $row.rest | into int
    let avg_speed = ($s * $d) / ($d + $r)
    {
      name: $row.name
      avg-speed: $avg_speed
      s: $s,
      r: $r,
      d: $d,
    }
  }
}

export def distance [time: int]: record -> int {
  let row = $in
  let cycle = $row.r + $row.d
  let n = $time // $cycle 
  let rem = $time mod $cycle
  let flight_time = $row.d * $n + ([$rem $row.d] | math min)
  ($flight_time * $row.s)
}
