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

# we can brute force this
# there are only 8! = 40320 different possible paths
def part1 [] {
  path-distances | math min
}


def part2 [] {
  path-distances | math max
}

def path-distances [] {
  let rows = $in 
  | split row "\n"
  | parse --regex '^(?<a>\w+) to (?<b>\w+) = (?<d>\d+)$'

  let map = $rows
  | each { |row| [$"($row.a),($row.b)", ($row.d | into int)] }
  | into record

  let cities = $rows
  | each { |row| [$row.a $row.b] }
  | flatten
  | uniq

  perms 8 
  | each { |p|
    $p 
    | window 2
    | each { |w|
      match $w {
        [$a $b] => {
          let c1 = $cities | get $a
          let c2 = $cities | get $b
          let d1 = $map | get -i $"($c1),($c2)"
          let d2 = $map | get -i $"($c2),($c1)"
          $d1 | default $d2
        
        }
      }
    }
    | math sum
  }
}
# https://en.wikipedia.org/wiki/Steinhaus%E2%80%93Johnson%E2%80%93Trotter_algorithm#Recursive_structure
# unoptimized Steinhaus-Johnson-Trotter algorithm
def perms [n: int]: any -> list<list<any>> {
  seq 1 $n 
  | reduce --fold [[]] { |_ acc| 
    $acc | each { |p| next-perms $p } | flatten
  }
}
def next-perms [p: list<any>]: any -> list<list<any>> {
  let n = $p | length
  seq 0 $n | each { |i| $p | insert $i $n }
}
