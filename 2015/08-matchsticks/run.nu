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
export def part1 [] {
  let chars = $in
  | parse --regex '\\(?<c>[\\x"])' 
  | get c
  | each { |x|
    let result = match $x {
      'x' => { 3 } 
      '\' => { 1 }
      '"' => { 1 }
      $_ => { 
        print "x = " $x
        0
      }
    }
    $result
  }
  | math sum

  let lines = $in | split row "\n" | length

  2 * $lines + $chars
}

def part2 [] {
  split row "\n"
  | each { |line| ($line | to nuon | str length) - ($line | str length) }
  | math sum
}

[
  '""'
  '"abc"'
  '"aaa\"aaa"'
  '"\x27"'
]
| part1
| print

