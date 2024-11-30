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
    1 => { part1 run }
    2 => { part2 run }
  }
}

def parse-buckets [] {
  split row "\n" 
  | each { try { into int } }
}


export module part1 {
  def run [] {
    # let buckets = [ 5, 5, 10, 15, 20 ]
    # print (count $buckets 25)
    # print $buckets

    # stor open | query db "select * from eggnog"
    let buckets = $in | parse-buckets  
    print (count $buckets 150)
  }
  def count [buckets: list<int>, eggnog: int] {
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
    if $j == 0 { return 1 }
    if $i < 0 { return 0 }
    if $j < 0 { return 0 }
    let rows = stor open | query db $"select n from eggnog where i = ($i) and j = ($j)"
    if ($rows | is-not-empty) { return $rows.0.n }

    let n = $buckets | get $i
    let result = (go $buckets ($i - 1) $j) + (go $buckets ($i - 1) ($j - $n))
    stor insert -t eggnog -d { i: $i, j: $j, n: $result }
    $result
  }
}

export module part2 {
  def run [] {
    let buckets = [ 5, 5, 10, 15, 20 ]
    print (count $buckets 25)
  }
  def count [buckets: list<int>, eggnog: int] {
    try { stor delete -t eggnog }
    stor create -t eggnog -c { i: int, q: int, c: int, n: int }
    stor open | query db "create index cache on eggnog(i, q, c)"

    let n = ($buckets | length) - 1
    for q in (seq 1 $eggnog) {
      for c in (seq 1 $q) {
        go $buckets $n $q $c
      }
    }

    seq 1 $eggnog
    | each { 
      let q = $in
      seq 1 $q | each { go $buckets $n $q $in }
    }
    | ignore

    stor open | query db $"select n from eggnog where i = ($n) and q = ($eggnog) order by $c desc"
  }

  # i is the index of the largest available bucket
  # q is amount of eggnog
  def go [buckets: list<int>, i: int, q: int, c: int] {
    if $q == 0 { return 1 }
    if $c <= 0 { return 0 }
    if $i < 0 { return 0 }
    if $q < 0 { return 0 }
    let rows = stor open | query db $"select n from eggnog where i = ($i) and q = ($q)"
    if ($rows | is-not-empty) { return $rows.0.n }

    let k = $buckets | get $i
    let n = (go $buckets ($i - 1) $q $c) + (go $buckets ($i - 1) ($q - $k) ($c - 1))
    stor insert -t eggnog -d { i: $i, q: $q, c: $c, n: $n }
    $n
  }
}
