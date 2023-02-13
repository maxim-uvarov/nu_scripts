def 'hist-save' [
	# count: int = 20
] {
	let name = $"history(date now | date format '%Y%m%d-%H%M%S')"

	history -l 
	| where session_id == (history session) 
	| get command
	| save $"/Users/user/apps-files/github/nushell_playing/($name).nu"
}


# def 'hist-save' [
# 	count: int = 20
# ] {
# 	let name = $"history(date now | date format '%Y%m%d-%H%M%S')"

# 	history
# 	| get command 
# 	| last $count 
# 	| save $"/Users/user/apps-files/github/nushell_playing/($name).nu"
# }
