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
  stor create -t conway -c { i: int, j: int, n: int, s: str }
  stor open | query db "create unique index lookup on conway(n,j,i)"

  $in 
  | split row "\n"
  | enumerate
  | each { 
    let j = $in.index
    $in.item
    | split chars
    | enumerate 
    | each {
      let i = $in.index
      let s = $in.item
      stor insert -t conway -d { i: $i, j: $j, n: 0, s: $s }
    }
  }

  for i in (seq 1 100) {
    conway $i
  }

  stor open | query db $"select COUNT\(s\) as count from conway where n = 100 and s = '#'" | first | get count
}

  # print "seed"
  # print (show ($map))
  # print "step 1"
  # print (show (conway $map))

  # seq 1 100
  # | reduce --fold $map { |_ acc| conway $acc }
  # | transpose 
  # | get column1

# export def live-neighbors [n: int, j: int, i: int] {
# }

export def is-live [n: int, j: int, i: int] {
  stor open 
  | query db $"select s from conway where n = ($n) and j = ($j) and i = ($i) and s = '#'"
  | is-not-empty
}

# writes the nth grid to sqlite based on the n-1 grid
export def conway [n: int] {
  seq 0 99
  | each { |i|
    seq 0 99 
    | each { |j|
      let neighbors = seq -1 1 
      | each { |k| 
        seq -1 1 
        | each { |l| 
          if $k == 0 and $l == 0 { return 0 }
          if (is-live ($n - 1) ($j - $l) ($i - $k)) { 1 } else { 0 }
        } 
      }
      | flatten
      | math sum
      let s = match (is-live ($n - 1) $j $i) {
        true if $neighbors >= 2 and $n <= 3 => { "#" }
        false if $neighbors == 3 => { "#" }
        _ => { "." }
      }
      stor insert -t conway -d {
        n: $n,
        j: $j,
        i: $i,
        s: $s
      }
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
  $"($i)-($j)"
}

def part2 [] {
}

