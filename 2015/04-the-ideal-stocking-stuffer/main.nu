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
  for $i in (seq 1 100_000_000) {
    let run = [$input $i] | str join | hash md5 | split chars | take while { $in == "0" } | length
    if $run >= 5 { 
      return $i 
    }
  }
}

def part2 [] {
  for $i in (seq 1 100_000_000) {
    let run = [$input $i] | str join | hash md5 | split chars | take while { $in == "0" } | length
    if $run >= 6 { 
      return $i 
    }
  }

}
