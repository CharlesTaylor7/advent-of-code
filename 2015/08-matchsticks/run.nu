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

export def capture [] {
  parse --regex '\\(?<c>[\\x"])' 
  | get c
}

# between 752 and 4941
def part1 [] {
  split row "\n"
  | parse --regex '\\(?<c>[\\x"])' 
  | get c
  | each { |x|
    match $x {
      'x' => { 3 } 
      '\' => { 1 }
      '"' => { 1 }
      $_ => { 
        print "x = " $x
        0
      }
    }
  }
  | math sum
  | $in + 2

}

def part2 [] {
}

