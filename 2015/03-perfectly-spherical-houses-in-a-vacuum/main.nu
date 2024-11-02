let dir = $env.CURRENT_FILE | path dirname
let input = open ($dir | path join "input.txt")

def nu-complete-part [] {
  [1 2]
}

export def main [part: int@"nu-complete-part"] {
  match $part {
    1 => (part1)
    2 => (part2)
  }
}

def part1 [] {
  let seed: list<list<int>> = [[0 0]]
  $input
  | split chars
  | reduce --fold $seed {|it acc|
    match ($acc | last) {
      [$x $y] => { 
        let next = match $it {
          ">" => [($x + 1) $y]
          "v" =>  [$x ($y + 1)]
          "<" => [($x - 1) $y]
          "^" => [$x ($y - 1)]
        }
        $acc | append [$next]
      } 
    }
  }
  | uniq
  | length
}


def part2 [] {
  let seed: list<list<int>> = [[0 0] [0 0]]
  $input
  | split chars
  | reduce --fold $seed {|it acc|
    match ($acc | last 2) {
      [[$x $y] $_] => { 
        let next = match $it {
          ">" => [($x + 1) $y]
          "v" =>  [$x ($y + 1)]
          "<" => [($x - 1) $y]
          "^" => [$x ($y - 1)]
        }
        $acc | append [$next]
      } 
    }
  }
  | uniq
  | length
}
