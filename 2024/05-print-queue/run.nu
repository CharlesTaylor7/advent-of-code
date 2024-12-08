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
  match (parse-input) {
    {$rules, $runs } => { $runs
      | filter { |run| is-sorted $run $rules }
      | each { median $in }

      | math sum
    }
  }
}

export def part2 [] {
  match (parse-input) {
    { $rules, $runs } => {
      $runs
      | filter { |run| not (is-sorted $run $rules) }
      | each { |run| sort-run $run $rules }
      | each { median $in }
      | math sum
    }
  }
}

export def parse-input [] {
  let sections = $in | split row "\n\n" 

  let rules = $sections.0 
  | parse -r '(?<a>\d+)\|(?<b>\d+)' 
  | each {
    { a: ($in.a | into int), b: ($in.b | into int) }
  }

  let runs = $sections.1 
  | split row "\n" 
  | filter { is-not-empty }
  | each { |row|
    $"[($row)]" | from json 
  } 
  { rules: $rules, runs: $runs }
}

export def median [run: list<int>]: nothing -> int {
  let k = ($run | length) // 2
  $run | get $k
}

export def sort-run [run: list<int>, rules: table]: nothing -> bool {
  let n = $run | length
  for $i in (seq 0 ($n - 1)) {
    let a = $run | get $i
    for $j in (seq ($i + 1) ($n - 1)) {
      let b = $run | get $j
      # print $"Checking ($a) < ($b)"
      if ($rules | any { |rule| $rule.a == $b and $rule.b == $a }) { 
        return false 
      }
    }
  }
  true
}

export def is-sorted [run: list<int>, rules: table]: nothing -> bool {
  let n = $run | length
  for $i in (seq 0 ($n - 1)) {
    let a = $run | get $i
    for $j in (seq ($i + 1) ($n - 1)) {
      let b = $run | get $j
      # print $"Checking ($a) < ($b)"
      if ($rules | any { |rule| $rule.a == $b and $rule.b == $a }) { 
        return false 
      }
    }
  }
  true
}
