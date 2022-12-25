# Print string colourfully
def cprint [
	...args
	--color (-c): string@'nu-complete colors' = 'default'
] {
	let text = if ($args == []) {
		$in
	} else {
		$args | str join ' '
	}

	$text | str join ' ' | print $'(ansi $color)($in)(ansi reset)' 
}

def 'nu-complete colors' [] {
	ansi --list | get name | each while {|it| if $it != 'reset' {$it} }
}