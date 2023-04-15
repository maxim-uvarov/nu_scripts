def 'hist-save' [
	# count: int = 20
	--dir: string = $"/Users/user/apps-files/github/nushell_playing/"
] {
	let name = $"history(date now | date format '%Y%m%d-%H%M%S')"

	history -l 
	| where session_id == (history session) 
	| get command
	| save $"($dir)/($name).nu"

	print $"file saved ($dir)/($name).nu"

	code $"($dir)/($name).nu"
}

def 'hs' [
	filename?
	--dir: string = $"/Users/user/apps-files/github/nushell_playing/"
	--open (-o)
	--up (-u) = 0
] {
	let name = ($filename | default ($"history(history session)"))

	if $up > 1 {
		history -l 
		| where session_id == (history session) 
		| get command
		| last ($up + 1)
		| drop 1
		| save $"($dir)/($name).nu" -a	
	} else {
		history -l 
		| where session_id == (history session) 
		| get command
		| filter {|i| ($i =~ "^let ") or ($i =~ "#") or ($i =~ "^def")}
		| append "\n\n"
		| prepend $"#($name)"
		| save $"($dir)/($name).nu" -a	
	}

	# print $"file saved ($dir)/($name).nu"

	if $open {
		code $"($dir)/($name).nu"
	}
}

def 'hs-line' [
	# count: int = 20
	--dir: string = $"/Users/user/apps-files/github/nushell_playing/"
	--open (-o)
] {
	let name = $"history(history session).nu"

	history -l 
	| where session_id == (history session) 
	| get command
	| last 2
	| first 1
	| save $"($dir)/($name).nu" -a

	# print $"file saved ($dir)/($name).nu"

	if $open {
		code $"($dir)/($name).nu"
	}
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
