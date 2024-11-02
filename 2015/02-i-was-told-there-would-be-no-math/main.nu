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
  $input
  | split row "\n"
  | each { 
    split row "x" 
    | each { into int }
    | match $in {
      [$a $b $c] => {
        let areas = [($a * $b) ($b * $c) ($a * $c)]
        let slack = $areas | math min
        let total = $areas | math sum | 2 * $in
        $total + $slack
      }
    }
  }
  | math sum

}

def part2 [] {
  $input
  | split row "\n"
  | each { 
    split row "x" 
    | each { into int }
    | match $in {
      [$a $b $c] => {
        let perimeter = [($a + $b) ($b + $c) ($a + $c)] | math min | 2 * $in
        let bow = $a * $b * $c
        $bow + $perimeter
      }
    }
  }
  | math sum


}
