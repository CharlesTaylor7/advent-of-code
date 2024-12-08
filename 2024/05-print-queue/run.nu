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
  # stor reset
  # stor create -t rules -c { a: int, b: int }
  # stor open | query db "create index after on rules(a)"
  # stor open | query db "create index before on rules(b)"
  
  let sections = $in | split row "\n\n" 

  # 1176 rules
  let rules = $sections.0 
  | parse -r '(?<a>\d+)\|(?<b>\d+)' 
  | each {
    { a: ($in.a | into int), b: ($in.b | into int) }
  }
  # 203 runs
  let runs = $sections.1 
  | split row "\n" 
  | filter { is-not-empty }
  | each { |row|
    $"[($row)]" | from json 
  } 
}

export def part2 [] {
}
