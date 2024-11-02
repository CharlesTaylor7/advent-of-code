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

def part1 [] {
  let wires = split row "\n" | each { parse-expr $in }
  let seed = { vars: {} wires: $wires }
  # let limit = 1
  let limit = 1_000
  seq 1 $limit 
  | reduce --fold $seed { |_ acc| 
    let seed = { vars: $acc.vars wires: [] }
    $acc.wires | reduce --fold $seed { |wire acc|

      # print $wire
      match (try-eval $acc.vars $wire) {
        [true $vars] =>  { vars: $vars wires: $acc.wires }
        [false $_] => { vars: $acc.vars wires: ($acc.wires | append $wire) }
      }
    }
  }
  | get vars.a
}

def part2 [] {
  let wires = split row "\n" | each { parse-expr $in }
  let seed = { vars: { b: 956 } wires: $wires }
  # let limit = 1
  let limit = 1_000
  seq 1 $limit 
  | reduce --fold $seed { |_ acc| 
    let seed = { vars: $acc.vars wires: [] }
    $acc.wires | reduce --fold $seed { |wire acc|
      match (try-eval --part2 $acc.vars $wire) {
        [true $vars] =>  { vars: $vars wires: $acc.wires }
        [false $_] => { vars: $acc.vars wires: ($acc.wires | append $wire) }
      }
    }
  }
  | get vars.a

}

export def try-int [val: string] {
  if $val =~ '\d' { $val | into int } else { $val }
}

def parse-expr [row: string] -> list {
  match ($row | parse --regex '(?<x>\w+) (?<op>\w+) (?<y>\w+) -> (?<r>\w+)') {
    [{ op: $op x: $x y: $y r: $r }] => { 
      return { 
        op: $op 
        x: (try-int $x)
        y: (try-int $y) 
        r: $r 
      }
    } 
  }

  match ($row | parse --regex 'NOT (?<x>\w+) -> (?<r>\w+)') {
    [{ x: $x r: $r }] => { 
      return { 
        op: NOT 
        x: $x 
        y: null 
        r: $r 
      }
    } 
  }

  match ($row | parse --regex '(?<x>\w+) -> (?<r>\w+)') {
    [{ x: $x r: $r }] => { 
      return { 
        op: null 
        x: (try-int $x)
        y: null 
        r: $r 
      } 
    }
  }
} 

def interpret [op?: string x?: int y?: int] {
  match $op {
    "NOT" => { $x | bits not }
    "RSHIFT" => { $x | bits shr $y -n 2 }
    "LSHIFT" => { $x | bits shl $y -n 2}
    "AND" => { $x | bits and $y }
    "OR" => { $x | bits or $y }
    null => { $x }
  }
}

def args [op?: string] {
  match $op {
    null => { 1 }
    "NOT" => { 1 }
    "RSHIFT" => { 2 }
    "LSHIFT" => { 2 }
    "AND" => { 2 }
    "OR" => { 2 }
  }
}

def try-eval [vars: record expr: record --part2] -> [bool, record] {
  if $part2 and $expr.r == "b" { return [true $vars] }

  let x = try-read $vars $expr.x
  if $x == null { return [false, $vars] }
  let y = try-read $vars $expr.y
  if $y == null and (args $expr.op) == 2 { return [false, $vars] }
  let result = interpret $expr.op $x $y
  let vars = $vars | insert $expr.r $result
  [true $vars]
}

def try-read [vars: record val: any] -> any {
  match ($val | describe) {
    "string" => { $vars | get -i $val }
    "int" => { $val }
    "nothing" => { null }
    $_ => { make error {} }
  }
}
