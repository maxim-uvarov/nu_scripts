# > 1..10 | wrap a | merge ($in | rename b) | abbreviate -c
# ╭─a──┬─b──╮
# │  1 │  1 │
# │  2 │  2 │
# │  3 │  3 │
# │ *  │ *  │
# │  8 │  8 │
# │  9 │  9 │
# │ 10 │ 10 │
# ╰────┴────╯
export def 'abbreviate' [
    --copy (-c) # strip ansi codes from output table and copy it to clipboard
] {
    let $value = $in
    let $val_length = ($value | length)

    if $val_length > 6 {
        $value | first 3
        | append ($value | columns | reduce -f {} {|col acc| $acc | merge {$col : '…'}})
        | append ($value | last 3)
    } else {
        $value
    }
    | if $copy {
        table
        | ansi strip
        | pbcopy
    } else {}
}

# output a command from a pipe where `example` used, and truncate an output table
export def example [
    --dont_copy (-C)
    --dont_comment (-H)
    --indentation_spaces (-i) = 1
] {
    let $in_table = ($in | abbreviate | table | ansi strip)

    history
    | last
    | get command
    | str replace -r '\| example.*' ''
    | $'> ($in)(char nl)($in_table)'
    | if not $dont_comment {
        lines
        | each {|i| $'#(seq 1 $indentation_spaces | each {" "} | str join '')($i)'}
        | str join (char nl)
    } else {}
    | if not $dont_copy {
        $in | clip
    } else {}
}