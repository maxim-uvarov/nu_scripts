def 'hist-save' [
	count: int = 20
] {
	let name = $"history(date now | date format '%Y%m%d-%H%M%S')"

	open $nu.history-path 
	| get history.command_line 
	| last $count 
	| save $"/Users/user/apps-files/github/nushell_playing/($name).nu"
}
