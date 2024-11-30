def dir [] {
  $env.CURRENT_FILE | path dirname
} 

def input [] {
  open (dir | path join "input.txt")
}

export def main [] {
  input | run
}

def parse-buckets [] {
  split row "\n" 
  | each { try { into int } }
}


def run [] {
  let buckets = [ 5, 5, 10, 15, 20 ]
  count $buckets 25
}

def count [buckets: list<int>, eggnog: int] {
  
  # try { stor delete -t eggnog }
  # stor create -t eggnog -c { i: int, q: int, c: int, n: int }
  # stor open | query db "create index cache on eggnog(i, q, c)"


  let n = ($buckets | length) - 1
  go $buckets $n $eggnog 2
  # for q in (seq 1 $eggnog) {
  #   for c in (seq 1 $q) {
  #     go $buckets $n $q $c
  #   }
  # }
  #
  # stor open | query db $"select n from eggnog where i = ($n) and q = ($eggnog) order by c desc"
}

# i is the index of the largest available bucket
# q is amount of eggnog
def go [buckets: list<int>, i: int, q: int, c: int] {
  if $q == 0 { return 1 }
  if $c <= 0 { return 0 }
  if $i < 0 { return 0 }
  if $q < 0 { return 0 }
  # let rows = stor open | query db $"select n from eggnog where i = ($i) and q = ($q)"
  # if ($rows | is-not-empty) { return $rows.0.n }

  let k = $buckets | get $i
  let n = (go $buckets ($i - 1) $q $c) + (go $buckets ($i - 1) ($q - $k) ($c - 1))
  # print [$i,$q,$c,$n]
  # stor insert -t eggnog -d { i: $i, q: $q, c: $c, n: $n }
  $n
}
