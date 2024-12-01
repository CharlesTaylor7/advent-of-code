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
    1 => (part1)
    2 => (part2)
  }
}

export def part1 [] {
  stor reset
  stor create -t conway -c { n: int, key: str }
  stor open | query db "create unique index lights on conway(n, key)"

  $in 
  | split row "\n"
  | enumerate
  | each { 
    let j = $in.index
    $in.item
    | split chars
    | enumerate 
    | each {
      let s = $in.item
      if $s != "#" { return }
      let i = $in.index
      stor insert -t conway -d { key: (key $i $j), n: 0 }
    }
  }

  for i in (seq 1 100) {
    conway $i
  }

  stor open | query db $"select COUNT\(*\) as count from conway where n = 100" | first | get count
}

  # print "seed"
  # print (show ($map))
  # print "step 1"
  # print (show (conway $map))

  # seq 1 100
  # | reduce --fold $map { |_ acc| conway $acc }
  # | transpose 
  # | get column1

export def live-neighbors [n: int, i: int, j: int] {
  let neighbors = seq -1 1 
      | each { |k| 
        seq -1 1 
        | each { |l| 
          if $k == 0 and $l == 0 { return }
          key ($i - $k) ($j - $l)
        } 
      }
      | flatten
      | str join ', '
  put neighbors

  let keys = []
  stor open 
  | query db $"select COUNT\(*\) as count from conway where n = ($n) and key in \(($neighbors)\)"
  | first
  | get count
}

export def is-live [n: int, i: int, j: int] {
  stor open 
  | query db $"select 1 from conway where n = ($n) and key = (key $i $j)"
  | is-not-empty
}

# writes the nth grid to sqlite based on the n-1 grid
export def conway [n: int] {
  seq 0 99
  | each { |i|
    seq 0 99 
    | each { |j|
      let k = live-neighbors ($n - 1) $i $j
      let live = match (is-live ($n - 1) $i $j) {
        true if $k >= 2 and $n <= 3 => { true }
        false if $k == 3 => { true }
        _ => { false }
      }
      if not $live { return }

      stor insert -t conway -d { n: $n, key: (key $i $j) }
    }
    | ignore
  }
  | ignore
}

def show [graph: record]: nothing -> string {
  seq 0 99
  | each { |j|
    seq 0 99 
    | each { |i|
        $graph | get (key ($i) ($j))
    }
    | str join ''
  }
  | str join "\n"
}

def key [i: int, j: int]: nothing -> string {
  if $i < 0 or $j < 0 or $i > 99 or $j > 99 { return }
  $"($i)-($j)"
}

def part2 [] {
}
