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

def part2 [] {
}

def parse-buckets [] {
  split row "\n" 
  | each { try { into int } }
}

# brute force without memoizing.
# add memoizing later
def part1 [] {
  let buckets = [ 5, 5, 10, 15, 20 ]
  print (count $buckets 25)
  print $buckets

  stor open | query db "select * from eggnog"
#   let buckets = $in | parse-buckets  
#   print (count $buckets 150)
}

export def count [buckets: list<int>, eggnog: int] {
  try { stor delete -t eggnog }
  stor create -t eggnog -c { i: int, j: int, n: int }
  stor open | query db "create index cache on eggnog(i, j)"

  let n = ($buckets | length) - 1
  seq 1 $eggnog
  | each { go $buckets $n $in }
  | last
}

# i is the index of the largest available bucket
# j is amount of eggnog
def go [buckets: list<int>, i: int, j: int] {
  if $i < 0 { return 0 }
  if $j < 0 { return 0 }
  if $j == 0 { return 1 }
  let rows = stor open | query db $"select n from eggnog where i = ($i) and j = ($j)"
  if ($rows | is-not-empty) { return $rows.0.n }

  let n = $buckets | get $i
  let without_i = (go $buckets ($i - 1) $j)
  let with_i = (go $buckets $i ($j - $n))
  # print { i: $i, j: $j, with: $with_i, without: $without_i }
  let result = $with_i + $without_i
  stor insert -t eggnog -d { i: $i, j: $j, n: $result }
  $result
}
