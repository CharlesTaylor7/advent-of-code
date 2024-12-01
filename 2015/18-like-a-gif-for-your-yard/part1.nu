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
# const rows = 6
# const cols = 6
# const steps = 4
const rows = 100
const cols = 100
const steps = 100

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

  # show 0
  for i in (seq 1 $steps) {
    print $i
    conway $i
    # show $i
  }

  stor open | query db $"select COUNT\(*\) as count from conway where n = ($steps)" | first | get count
}


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
      | each { $"'($in)'" }
      | str join ', '

  let keys = []
  stor open 
  | query db $"select COUNT\(*\) as count from conway where n = ($n) and key in \(($neighbors)\)"
  | first
  | get count
}

export def is-live [n: int, i: int, j: int] {
  stor open 
  | query db $"select 1 from conway where n = ($n) and key = \'(key $i $j)\'"
  | is-not-empty
}

# writes the nth grid to sqlite based on the n-1 grid
export def conway [n: int] {
  seq 0 ($cols - 1)
  | each { |i|
    seq 0 ($rows - 1)  
    | each { |j|
      let k = live-neighbors ($n - 1) $i $j
      let live = match (is-live ($n - 1) $i $j) {
        true if $k >= 2 and $k <= 3 => { true }
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

export def show [n: int] {
  seq 0 ($rows - 1)
  | each { |j|
    seq 0 ($cols - 1)
    | each { |i|
        if (is-live $n $i $j) { "#" } else { "." }
    }
    | str join ''
    | print $in
  }
  | ignore 
}

def key [i: int, j: int]: nothing -> string {
  if $i < 0 or $j < 0 or $i >= $cols or $j >= $rows { return }
  $"($i)-($j)"
}

def part2 [] {
}
