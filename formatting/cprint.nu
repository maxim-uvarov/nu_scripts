# Print string colourfully
def cprint [
	...args
	--color (-c): string@'nu-complete colors' = 'default'
	--no_newline (-n)
] {
	let text = if ($args == []) {
		$in
	} else {
		$args | str join ' '
	}

	let n_flag = if ($no_newline) {
		"--no-newline"
	} else {
		""
	}

	$text | str join ' ' | ^"print ($n_flag)" $'(ansi $color)($in)(ansi reset)' 
}

def 'nu-complete colors' [] {
	ansi --list | get name | each while {|it| if $it != 'reset' {$it} }
}