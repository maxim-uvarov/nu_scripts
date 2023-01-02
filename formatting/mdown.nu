def mdline [text] {
	let t1 =  {
		'**': $'(ansi -e {attr: b})', 
		'*': $'(ansi -e {attr: i})', 
		'_': $'(ansi -e {attr: u})'
	}

	let t2 = {
		'**': $'(ansi reset)', 
		'*': $'(ansi reset)', 
		'_': $'(ansi reset)'
	}

	$text
    | split row " "
    | each {
        |it2|
        $it2
        | parse -r "^(?<start>\\*{1,2}|_)?(?<a>.+?)(?<end>\\*{1,2}|_)?$"
        | upsert fin {
            |i|  $"($t1 | get -i $i.start)($i.a)($t2 | get -i $i.end)"
        }
        | get fin
        | str join " "
     } | str join " "
 }

def mdown [text] {

	let rows1 = (
		$text
		| split row "\n"
		| each {
			|it| mdline $it
		} | str join "\n"
	)

	$rows1
}