# Print string colourfully
def cecho [
    ...args
    --color (-c): string@'nu-complete colors' = 'default'
    --frame (-f): string
    --before (-b): int = 0
    --after (-a): int = 1
    --remleadspaces (-r)
    --indent (-i) = 0
    --width (-w) = 120
    --print (-p)
    --md (-M)
    --mdcolor (-m): string@'nu-complete colors' = 'green'
] {
    mut text = if ($args == []) {
        $in
    } else {
        $args | str join ' '
    }

    if $remleadspaces {
        $text = (
            $text 
            | split row "\n"
            | each {
                |i| $i 
                | str replace "^[ \t]+" ""
            }
            | str join "\n"
        )
    }


    if $indent > 0 {
        let indent_spaces = (seq 1 $indent | each {|i| " "} | str join "")

        $text = (
            $text 
            | split row "\n"
            | each {
                |i| [$indent_spaces $i] | str join ""
            }
            | str join "\n"
        )
    }

    if (not $md) {
        $text = (mdown $text -c $mdcolor)
    }

    if $frame != null {
        let width = (term size | get columns)
        $text = ( [
            (seq 1 $width | each {|i| $frame} | str join "")
            $text 
            (seq 1 $width | each {|i| $frame} | str join "")
        ] | str join "\n" )
    }

    let output = ([
        (seq 1 $before | each {|i| "\n"} | str join "")
        $"(ansi $color)($text)(ansi reset)"
        (seq 1 $after | each {|i| "\n"} | str join "")
    ] | str join "")

    if $print {
        print $output
    } else {
        $output
    }
}

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
            | get fin -i
            | str join " "
         } | str join " "
    } | str join "\n"
}

def 'nu-complete colors' [] {
    ansi --list | get name | each while {|it| if $it != 'reset' {$it} }
}

