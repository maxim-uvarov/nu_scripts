# Print string colourfully
export def 'cprint' [
    ...args
    --color (-c): any = 'default'
    --highlight_color (-h): any = 'green_bold'
    --frame_color (-r): any = 'dark_gray'
    --frame (-f): string        # A symbol (or a string) to frame text
    --before (-b): int = 0      # A number of new lines before text
    --after (-a): int = 1       # A number of new lines after text
    --echo (-e)                 # Echo text string instead of printing
] {
    let $in_text = ($in | default ($args | str join ' '))

    def compactit [] {
        $in 
        | str replace -a '(\n[\t ]+(\n[\t ]+)+)' '⏎' 
        | str replace -a '\n?[\t ]+' ' ' 
        | str replace -a '⏎' "\n\n" 
        | str trim
    }

    def colorit [] {
        let text = ($in | split chars)
        mut agg = []
        mut open_tag = true

        for i in $text {
            if $i == '*' {
                if $open_tag {
                    $open_tag = false 
                    $agg = ($agg | append $'(ansi reset)(ansi $highlight_color)')
                } else {
                    $open_tag = true
                    $agg = ($agg | append $'(ansi reset)(ansi $color)')
                }
            } else {
                $agg = ($agg | append $i)
            }
        }

        $agg
        | str join ''
        | $'(ansi $color)($in)(ansi reset)'
    }

    def frameit [] {
        let $text = $in
        let $width = (
            term size 
            | get columns 
            | ($in / ($frame | str length) | math round) 
            | $in - 1
            | [$in 1]
            | math max  # term size gives 0 in tests
        )
        let $line = (
            ' ' 
            | fill -a r -w $width -c $frame 
            | $'(ansi $frame_color)($in)(ansi reset)'
        )

        (
            $line + "\n" + $text + "\n" + $line
        )
    }

    def newlineit [] {
        let $text = $in

        print ("\n" * $before) -n
        print $text -n
        print ("\n" * $after) -n
    }

    (
        $in_text
        | compactit
        | colorit
        | if $frame != null {
            frameit
        } else {}
        | if $echo { } else { newlineit }
    )
}