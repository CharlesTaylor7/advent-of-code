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
    1 => (part1)
    2 => (part2)
  }
}

const regex = '\w+: capacity (?<capacity>-?\d+), durability (?<durability>-?\d+), flavor (?<flavor>-?\d+), texture (?<texture>-?\d+), calories (?<calories>-?\d+)'

# dumb but works
# just start at an arbitrary point walk towards a local maximum
export def part1 [] {
  let costs = $in | parse -r $regex 
  print $costs 
  mut partition = [25 25 25 25]
  mut max = eval $costs $partition
  mut continue = true
  while $continue {
    $continue = false
    for i in (seq 0 3) {
      for j in (seq 0 3 | filter { $in != $i }) {
        let p = $partition | update $i { $in + 1 } | update $j { $in - 1 }
        let score = eval $costs $p
        if $score > $max {
          $max = $score
          $partition = $p
          $continue = true
        }
      }
    } 
  }
  print $partition
  $max
}

export def part2 [] {
}


export def eval [costs: table, amounts: list<int>] {
  let a =  $costs | get capacity | zip $amounts | each { |pair| ($pair.0 | into int) * $pair.1 } | math sum
  let b = $costs | get durability | zip $amounts | each { |pair| ($pair.0 | into int) * $pair.1 } | math sum
  let c = $costs | get flavor | zip $amounts | each { |pair| ($pair.0 | into int) * $pair.1 } | math sum
  let d = $costs | get texture | zip $amounts | each { |pair| ($pair.0 | into int) * $pair.1 } | math sum
  if $a <= 0 or $b <= 0 or $c <= 0 or $d <= 0 { 
    0 
  } else {
    $a * $b * $c * $d
  }
}

export def next-layer []: list<int> -> list<any> {
  let buckets = $in
  let n = $buckets | length 
  seq 0 ($n - 1) 
  | each { |i| $buckets | update $i { $in + 1 } }
}
