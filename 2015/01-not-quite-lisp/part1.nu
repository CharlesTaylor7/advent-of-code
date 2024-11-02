let dir = $env.CURRENT_FILE | path dirname
let input = open ($dir | path join "input.txt")

let total = $input | str length
let down = $input
| split chars 
| filter { $in == ")" }
| length

print ($total - 2 * $down)
