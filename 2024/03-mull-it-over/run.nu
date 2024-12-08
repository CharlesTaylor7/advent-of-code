export def input [] {
  $env.CURRENT_FILE 
  | path dirname
  | path join "input.txt"
  | open $in
}

def nu-complete-part [] {
  [1 2]
}

def main [part: int@"nu-complete-part"] {
  input | match $part {
    1 => (part1)
    2 => (part2)
  }
}

export def part1 [] {
  parse -r 'mul\((?<a>\d+),(?<b>\d+)\)'
  | each { [$in.a, $in.b] | into int | math product }
  | math sum
}
const regex = r#'(mul\((?<a>\d+),(?<b>\d+)\)|do\(\)|don't\(\))'#
export def part2 [] {
  parse -r $regex
  | reduce --fold { doing: true, value: 0 } { |it acc|
    match ($it.capture0 | split row "(" | first) {
      "mul" => {
        if $acc.doing {
          $acc | update value { $in + ([$it.a, $it.b] | into int | math product) }
        } else { 
          $acc 
        }
      }
      "do" => { $acc | update doing true }
      "don't" => { $acc | update doing false }
    }
  }
  | get value
}
