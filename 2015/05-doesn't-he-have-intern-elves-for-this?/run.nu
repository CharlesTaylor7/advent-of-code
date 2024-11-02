
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
  split row "\n"
  | where { is-nice-1 }
  | length
}

def part2 [] {
  split row "\n"
  | where { is-nice-2 }
  | length
}

export def is-nice-1 []: string -> bool {
  let word = $in
  not ($word | has-forbidden-substring) and ($word | has-atleast-3-vowels) and ($word | has-double)
}

def has-forbidden-substring [] {
  $in =~ '(ab|cd|pq|xy)'
}

def has-atleast-3-vowels [] {
  split chars | where { $in =~ '[aeiou]' } | take 3 | length | $in == 3
}

def has-double [] {
  split chars | window 2 | any { 
    match $in {
      [$a $b] => { $a == $b }
    }
  }
}

export def is-nice-2 []: string -> bool {
  let word = $in
  ($word | has-sandwich) and ($word | has-duplicated-pair)
}

def has-sandwich [] {
  split chars | window 3 | any { 
    match $in {
      [$a $_ $c] => { $a == $c }
    }
  }
}

export def has-duplicated-pair [] {
  let word = $in
  let n = $word | str length
  seq 0 ($n - 2)
  | any { |i|
    let pair = $word | str substring $i..($i + 1)
    let rest = $word | str substring ($i + 2)..$n
    $rest =~ $pair 
  }
}
