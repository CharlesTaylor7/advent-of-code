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

const names = [Alice Bob Carol David Eric Frank George Mallory]

def part1 []: string -> int {
  let table = $in | parse-table
  maximize-happiness $table $names
}

def part2 []: string -> int {
  let table = $in | parse-table 
  let names = $names | append "Me"
  maximize-happiness $table $names
}

def parse-table [] {
  parse -r '(?<name1>\w+) would (?<act>gain|lose) (?<units>\d+) happiness units by sitting next to (?<name2>\w+)\.'
  | each { |row|
    let happiness = match $row.act {
      "gain" => { $row.units | into int }
      "lose" => { $row.units | into int | $in * -1 }
    }

    {
      pair: (key $row.name1 $row.name2)
      happiness: $happiness
    }
  }
  | group-by pair
  | transpose key value
  | each { |row| [$row.key, ($row.value | get happiness | math sum  )] }
  | into record
}

def maximize-happiness [ table: record, names: list<string> ] {
  let happiness = { |a, b| 
    let a = $names | get $a
    let b = $names | get $b
    let key = key $a $b
    $table | get -i (key $a $b) | default 0
  }

  perms ($names | length)
  | each { |p|
    $p  
    | window 2
    | each { |w| do $happiness $w.0 $w.1 }
    | math sum
    | $in + (do $happiness ($p | first) ($p | last))
  }
  | math max
}

def key [a: string b: string] {
  if $a < $b { 
    $"($a)-($b)" 
  } else { 
    $"($b)-($a)" 
  }
}

# https://en.wikipedia.org/wiki/Steinhaus%E2%80%93Johnson%E2%80%93Trotter_algorithm#Recursive_structure
# unoptimized Steinhaus-Johnson-Trotter algorithm
export def perms [n: int]: any -> list<list<any>> {
  seq 0 ($n - 1)
  | reduce --fold [[]] { |_ acc| 
    $acc | each { |p| next-perms $p } | flatten
  }
}
def next-perms [p: list<any>]: any -> list<list<any>> {
  let n = $p | length
  seq 0 $n | each { |i| $p | insert $i $n }
}
