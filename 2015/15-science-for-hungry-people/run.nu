export def input [] {
  $env.CURRENT_FILE 
  | path dirname
  | path join "input.txt"
  | open $in
}

def nu-complete-part [] {
  [1 2]
}

export def main [part: int@"nu-complete-part"] {
  input 
  | match $part {
    1 => (part1)
    2 => (part2)
  }
}

const regex = '\w+: capacity (?<capacity>-?\d+), durability (?<durability>-?\d+), flavor (?<flavor>-?\d+), texture (?<texture>-?\d+), calories (?<calories>-?\d+)'

# dumb but works
# just start at an arbitrary point walk towards a local maximum
export def part1 [] {
  let costs = $in | parse -r $regex 
  mut partition = [25 25 25 25]
  mut max = eval $costs $partition
  mut continue = true
  while $continue {
    $continue = false
    for i in (seq 0 3) {
      for j in (seq 0 3 | filter { $in != $i }) {
        let p = $partition | update $i { $in + 1 } | update $j { $in - 1 }
        let score = taste $costs $p
        if $score > $max {
          $max = $score
          $partition = $p
          $continue = true
        }
      }
    } 
  }
  $max
}

export def part2 [] {
  
}

export def calories [costs: table, amounts: list<int>] {
  $costs | get calories | into int | zip $amounts | each { |pair| $pair.0 * $pair.1 } | math sum
}

export def taste [costs: table, amounts: list<int>] {
  let a =  $costs | get capacity | into int | zip $amounts | each { |pair| $pair.0 * $pair.1 } | math sum
  let b = $costs | get durability | into int | zip $amounts | each { |pair| $pair.0 * $pair.1 } | math sum
  let c = $costs | get flavor | into int | zip $amounts | each { |pair| $pair.0 * $pair.1 } | math sum
  let d = $costs | get texture | into int | zip $amounts | each { |pair| $pair.0 * $pair.1 } | math sum
  if $a <= 0 or $b <= 0 or $c <= 0 or $d <= 0 { 
    0 
  } else {
    $a * $b * $c * $d
  }
}



def count [buckets: list<int>, calories: int] {
  stor reset
  stor create -t calories -c { i: int, q: int, n: int }
  stor open | query db "create index cache on calories(i, q)"

  let n = ($buckets | length) - 1
  seq 1 $calories
  | each { go $buckets $n $in }
  | last
}

# i is the index of the largest available bucket
# q is amount of eggnog
def go [buckets: list<int>, i: int, q: int] {
  if $q == 0 { return 1 }
  if $i < 0 { return 0 }
  if $q < 0 { return 0 }
  let rows = stor open | query db $"select n from calories where i = ($i) and q = ($q)"
  if ($rows | is-not-empty) { return $rows.0.n }

  let k = $buckets | get $i
  let n = (go $buckets ($i - 1) $q) + (go $buckets ($i - 1) ($q - $k))
  stor insert -t eggnog -d { i: $i, q: $q, n: $n }
  $n
}
