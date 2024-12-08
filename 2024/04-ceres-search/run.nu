export def input [] {
  $env.CURRENT_FILE 
  | path dirname
  | path join "input.txt"
  | open $in
}

def nu-complete-part [] {
  [1 2]
}

export const example = "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"

def main [part: int@"nu-complete-part"] {
  input | match $part {
    1 => (part1)
    2 => (part2)
  }
}

export def part1 [] {
  let grid = split row "\n" | each { split chars }
  let n = $grid | first | length
  [
    (diagonals-1 $n)
    (diagonals-2 $n)
    (diagonals-3 $n)
    (diagonals-4 $n)
  ]
  | flatten
  | each { |line| 
    if ($line | length) < 4 { return null }
    $line | each { |cell| $grid | get $cell.row | get $cell.col }
  }
  | append [(rows $grid)]
  | append [(cols $grid $n)]
  | each { 
    window 4
    | filter { str join | $in == "XMAS" or $in == "SAMX" }
    | length
  }
  | math sum


    # $grid | get $line.row | get $line.col }
  # | append (rows $grid)
  # | append (cols $grid $n)
}


export def rows [map] {
  $map
}

export def cols [map: list, n: int] {
  seq 0 ($n - 1) 
  | each { |i| $map | get $i }
}

# left side diagonally down and to the right
export def diagonals-1 [n: int] {
  seq 0 ($n - 1) 
  | each { |j| 
    seq 0 ($n - $j - 1) 
    | each { |k| 
      { row: ($j + $k), col: $k }
    }
  }
}

# top side diagonally down and to the right
export def diagonals-2 [n: int] {
  seq 1 ($n - 1) 
  | each { |i| 
    seq 0 ($n - $i - 1) 
    | each { |k| 
      { row: $k,  col: ($i + $k) }
    }
  }
}


# left side diagonally up and to the right
export def diagonals-3 [n: int] {
  seq 0 ($n - 1) 
  | each { |j| 
    seq 0 $j
    | each { |k| 
      { row: ($j - $k), col: $k }
    }
  }
}


# right side diagonally down and to the left
export def diagonals-4 [n: int] {
  seq 1 ($n - 1) 
  | each { |i| 
    seq 0 ($n - $i - 1)
    | each { |k| 
      { row: ($i + $k) col: ($n - 1 - $k) }
    }
  }
}


export def part2 [] {
}
