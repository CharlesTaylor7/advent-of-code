export def input [] {
  $env.CURRENT_FILE 
  | path dirname
  | path join "input.txt"
  | open $in
}

def nu-complete-part [] {
  [1 2]
}

def main [part: int@"nu-complete-part"] {
  input | match $part {
    1 => (part1)
    2 => (part2)
  }
}

export def part1 [] {
  stor reset
  stor create -t obstacles -c { row: int, col: int }
  stor create -t visited -c { row: int, col: int }
  stor open | query db "create index o_row on obstacles(row, col)"
  stor open | query db "create index o_col on obstacles(col, row)"
  stor open | query db "create unique index v on visited(col, row)"
  mut position = $in | split row "\n" | enumerate | each { |pair| 
    let row = $pair.index
    $pair.item | split chars | enumerate | each { |pair|
      let col = $pair.index
      let c = $pair.item
      match $pair.item {
        "#" => { stor insert -t obstacles -d { row: $row, col: $col } | ignore }
        "." => { }
        "^" => { { row: $row, col: $col } }
      }
    }
  } | filter { is-not-empty } | first | first
  stor insert -t visited -d $position

  mut direction = "up"
  loop {
    let query = match $direction {
      "up" => $"select row, col from obstacles where col = ($position.col) and row < ($position.row) limit 1",
      "down" => $"select row, col from obstacles where col = ($position.col) and row > ($position.row) limit 1",
      "left" => $"select row, col from obstacles where row = ($position.row) and col < ($position.col) limit 1",
      "right" => $"select row, col from obstacles where row = ($position.row) and col > ($position.col) limit 1",
    }
    let result = stor open | query db $query
    if ($result | is-empty) {
      return (stor open | query db "select count(*) as count from visited" | first | get count)
    }
    let obstacle = $result | first
    let current = $position
    let to_visit = match $direction {
      "up" => { seq ($obstacle.row + 1) | each { |row| { row: $row, col: $current.col } } },
      "down" => { seq $current.row ($obstacle.row - 1) | each { |row| { row: $row, col: $current.col } } },
    }

    if ($to_visit | is-empty) {
      $direction = $direction | turn
    } else {
      $position = $to_visit | last
      $direction = $direction | turn
    }
  }
}

export def turn [] {
  match $in {
    "up" => "right",
    "right" => "down",
    "down" => "left",
    "left" => "up",
  }
}



export def part2 [] {
}
