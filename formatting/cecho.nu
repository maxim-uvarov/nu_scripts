# Print string colourfully
def cecho [
    ...args
    --color (-c): string@'nu-complete colors' = 'default'
    --frame (-f): string
    --framecolor: string@'nu-complete colors' = 'default'
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
        $text = (mdown $text --mdcolor $mdcolor --defcolor $color )
    } else {
        $text = $"(ansi $color)($text)(ansi reset)"
    }

    if $frame != null {
        let width = (term size | get columns)
        $text = ( [
            (seq 1 $width | each {|i| $frame} | str join "" | $"(ansi ($framecolor))($in)(ansi reset)" ) 
            $text 
            (seq 1 $width | each {|i| $frame} | str join "" | $"(ansi ($framecolor))($in)(ansi reset)")
        ] | str join "\n" )
    }

    let output = ([
        (seq 1 $before | each {|i| "\n"} | str join "")
        $text
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
    --mdcolor (-c) = green
    --defcolor (-d) = default
] {

    let t1 =  {
        '**': $'(ansi reset)(ansi -e {fg: ($mdcolor) attr: b})', 
        '*': $'(ansi reset)(ansi -e {fg: ($mdcolor) attr: i})', 
        '_': $'(ansi reset)(ansi -e {fg: ($mdcolor) attr: u})'
    }

    let t2 = {
        '**': $'(ansi reset)(ansi -e {fg: ($defcolor)})', 
        '*': $'(ansi reset)(ansi -e {fg: ($defcolor)})', 
        '_': $'(ansi reset)(ansi -e {fg: ($defcolor)})'
    }

    $text
    | $"(ansi -e {fg: ($defcolor)})($text)(ansi reset)"
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
            | get -i fin 
            | str join ""
         } | str join " "
    } | str join "\n"
}

def 'nu-complete colors' [] {
    ansi --list | get name | each while {|it| if $it != 'reset' {$it} }
}

