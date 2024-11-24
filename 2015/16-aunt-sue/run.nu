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
  input 
  | match $part {
    1 => part1
    2 => part2
  }
}



const sue = {
  children: 3
  cats: 7
  samoyeds: 2
  pomeranians: 3
  akitas: 0
  vizslas: 0
  goldfish: 5
  trees: 3
  cars: 2
  perfumes: 1
}

def parse-sues [] {
  split row "\n"
  | each {
    let match = parse -r 'Sue (?<sue>\d+): (?<props>.+)' | first  
    print $match
    let props = $match 
    | get props
    | split row ", " 
    | each { 
      let pair = $in | split row ": "
      { key: $pair.0, value: ($pair.1 | into int) }
    }
    { sue: $match.sue, props: $props }
  }
}
  
def part1 [] {
  parse-sues 
  | filter { 
    get props | all { |p| 
        ($sue | get $p.key) == $p.value 
    }
  }
  | to json
 }

def part2 [] {
  parse-sues
  | filter { 
    get props | all { |p| 
      match $p.key {
        "cats" => { ($sue | get $p.key) < $p.value }
        "trees" => { ($sue | get $p.key) < $p.value }
        "pomeranians" => { ($sue | get $p.key) > $p.value }
        "goldfish" => { ($sue | get $p.key) > $p.value }
        _ => { ($sue | get $p.key) == $p.value }
      }
    }
  }
  | to json
}
