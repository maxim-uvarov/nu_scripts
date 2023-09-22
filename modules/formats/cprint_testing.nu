export use cprint.nu

let $text = (open TheSongoftheFalcon.txt)

cprint $text --keep_single_breaks --indent 4

cprint '' --frame '?'

cprint $text --before 3 --echo