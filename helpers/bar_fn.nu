#bar_fn
let blocks = ["▏" "▎" "▍" "▌" "▋" "▊" "▉" "█"]
let percent = 0.33
let width = 10
# let blocks = [" " "▏" "▎" "▍" "▌" "▋" "▊" "▉" "█"]
def 'bar' [
  percent
  width
] {
    $"($blocks.7 * ($percent * $width // 1))($blocks | get (($percent * $width) mod 1 | $in * 8 | math floor))" | fill -c $' ' -w $width | $"(ansi -e {fg: yellow, bg: red})($in)(ansi reset)"
    }



