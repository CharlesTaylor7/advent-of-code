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
  match $part {
    1 => (input | part1)
    2 => (input | part2)
  }
}

def part1 [] {
  mut p = $in | str trim
  loop {
    $p = $p | inc
    if ($p | valid-rule-1) and ($p | valid-rule-2) and ($p | valid-rule-3) { break }
  }
  $p
}

def part2 [] {
  part1 | part1
}


export def int-to-char [] {
  char --integer $in
}


export def char-to-int [] {
  into binary | into int
}

export def inc-char [] {
  char-to-int | $in + 1 | int-to-char
}

export def inc [] {
  split chars | reverse | reduce --fold {carry: true, result: ''} { |it, acc|
      if $acc.carry {
        if $it == 'z' {
          { carry: true, result: ('a' + $acc.result) }
        } else {
          { carry: false, result: ( ($it | inc-char) + $acc.result) }
        }
      } else {
        { carry: false, result: ($it + $acc.result) }
    }
  }
  | get result
}

export def valid-rule-1 [] {
  $in =~ '(abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)'
}

export def valid-rule-2 [] {
  $in !~ '[iol]'
}

export def valid-rule-3 [] {
  split chars 
  | window 2 
  # maintain a list of letters that have doubled
  | reduce --fold [] { |it, acc|
    if $it.0 == $it.1 and $it.0 not-in $acc {
      $acc | append $it.0
    } else {
      $acc
    }
  }
  | length
  | $in >= 2
}
