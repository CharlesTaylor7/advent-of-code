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

def tri-num [x y] {

}
def part1 [] {

  mut i = 0
  for y in (seq 1 6) {
    for x in (seq 1 $y) {
       
      $i += 1
      print $"($x), ($y), ($i)"
    }
  }
}

def part2 [] {
}

