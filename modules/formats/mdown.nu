def mdown [
	text
	--mdcolor (-c) = default
] {

	let t1 =  {
		'**': $'(ansi -e {fg: ($mdcolor) attr: b})', 
		'*': $'(ansi -e {fg: ($mdcolor) attr: i})', 
		'_': $'(ansi -e {fg: ($mdcolor) attr: u})'
	}

	let t2 = {
		'**': $'(ansi reset)', 
		'*': $'(ansi reset)', 
		'_': $'(ansi reset)'
	}

	$text
	| split row "\n"
	| each {
		|l| $l 
	    | split row " "
	    | each {
	        |w|
	        $w
	        | parse -r "^(?<start>\\*{1,2}|_)?(?<a>.+?)(?<end>\\*{1,2}|_)?$"
	        | upsert fin {
	            |i|  $"($t1 | get -i $i.start)($i.a)($t2 | get -i $i.end)"
	        }
	        | get fin
	        | str join " "
	     } | str join " "
	} | str join "\n"
}