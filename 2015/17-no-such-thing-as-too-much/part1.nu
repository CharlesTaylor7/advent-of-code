def dir [] {
  $env.CURRENT_FILE | path dirname
} 

def input [] {
  open (dir | path join "input.txt")
}

def main [] {
    let buckets = [ 5, 5, 10, 15, 20 ]
    print (count $buckets 25)

    let buckets = input | parse-buckets  
    print (count $buckets 150)
}

def parse-buckets [] {
  split row "\n" 
  | each { try { into int } }
}


def count [buckets: list<int>, eggnog: int] {
  stor reset
  stor create -t eggnog -c { i: int, q: int, n: int }
  stor open | query db "create index cache on eggnog(i, q)"

  let n = ($buckets | length) - 1
  seq 1 $eggnog
  | each { go $buckets $n $in }
  | last
}

# i is the index of the largest available bucket
# q is amount of eggnog
def go [buckets: list<int>, i: int, q: int] {
  if $q == 0 { return 1 }
  if $i < 0 { return 0 }
  if $q < 0 { return 0 }
  let rows = stor open | query db $"select n from eggnog where i = ($i) and q = ($q)"
  if ($rows | is-not-empty) { return $rows.0.n }

  let k = $buckets | get $i
  let n = (go $buckets ($i - 1) $q) + (go $buckets ($i - 1) ($q - $k))
  stor insert -t eggnog -d { i: $i, q: $q, n: $n }
  $n
}
