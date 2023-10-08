# Format big numbers nicely
export def number-format [
    num                             # Number to format
    --thousands_delim (-t) = '_'    # Thousands delimiter: number-format 1000 -t ': 1'000
    --integers (-w) = 0    # Length of padding whole-part digits: number-format 123 -w 6:    123
    --decimals (-d) = 0       # Number of digits after decimal delimiter: number-format 1000.1234 -d 2: 1000.12
    --denom (-D) = ''               # Denom `--denom "Wt": number-format 1000 --denom 'Wt': 1000Wt
] {

    let parts = (
        $num
        | into string
        | split row "."
    )

    let $whole_part = (
        $parts.0
        | split chars
        | reverse
        | enumerate
        | reduce -f [] { |it, acc|
            $acc
            | append $it.item
            | if ((($it.index + 1) mod 3) == 0) {
                append $thousands_delim
            } else { }
        }
        | reverse
        | if ($in | first) == $thousands_delim {
            skip 1
        } else { }
        | str join ''
        | if $integers == 0 { } else {
            fill -w $integers -c ' ' -a r
        }
    )

    let dec_part = (
        if ($parts | length) == 1 { # i.e. there are no symbols after '.' in the given number
            "0"
        } else {
            $parts.1
        }
    )

    let dec_part2 = (
        if $decimals == 0 {
            ''
        } else {
            $".($dec_part | str substring 0..$decimals)"
            | fill -w ($decimals + 1) -c '0' -a l
        }
    )

    $"(ansi green)($whole_part)($dec_part2)(ansi reset)(ansi green_bold)($denom)(ansi reset)"
}