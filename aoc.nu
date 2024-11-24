export def start [year: int@"nu-complete-year" day: int@"nu-complete-day" template?: string@"nu-complete-template"] {
  let page = http get $"https://adventofcode.com/($year)/day/($day)" 

  let title = $page
  | query web -q 'h2'
  | first
  | first
  | parse --regex '^--- Day \d+: (?<title>.*?) ---$'
  | get title
  | first
  | split row --regex '[ ,]+'
  | str downcase
  | str join "-"

  let dir = $"($year)/($day | fill -w 2 -c 0 -a r)-($title)"
  mkdir $dir

  let description = $page
  | query web -q "article.day-desc" -m
  | save -f $"($dir)/description.txt"

  http get $"https://adventofcode.com/($year)/day/($day)/input" --headers [Cookie (cookie)]
  | save -f $"($dir)/input.txt"

  if $template != null {
    let template = $"templates/($template)/*" | into glob
    cp -r $template $dir
  }
}

export def answer [year: int@"nu-complete-year" day: int@"nu-complete-day" level: int@"nu-complete-level" answer: int] {
  let body = $"level=($level)&answer=($answer)"
  let headers = [
    Cookie (cookie) 
    "Sec-Fetch-Site" "cross-site"
    "Content-Type" "application/x-www-form-urlencoded"
  ]

  http post $"https://adventofcode.com/($year)/day/($day)/answer" --headers $headers $body
}

export def check [year: int@"nu-complete-year"] {
  let stars = http get $"https://adventofcode.com/($year)" --headers [Cookie (cookie)]
  | query web -q "pre.calendar > a" -a aria-label
  | parse --regex '^Day (?<day>\d+), (?<count>one|two) stars?$'
  | each { |row| 
    let day = $row.day | into int
    let stars = if $row.count == one { 1 } else { 2 }
    [$day $stars]
  }
  | into record

  seq 1 25
  | each { |i| [$i, ($stars | get -i ($i | into string) | default 0)] }
  | into record
}

def read-dotenv [] {
  open .env 
  | split row "\n" 
  | each { split row "=" }
  | into record
}

def cookie [] {
  $"session=(read-dotenv | get COOKIE_SESSION_ID)"
}

def nu-complete-year [] {
  seq 2015 2024
}

def nu-complete-day [] {
  seq 1 25
}

def nu-complete-level [] {
  seq 1 2
}

def nu-complete-template [] {
  [
    nu
    rust
    typescript
  ]
}
