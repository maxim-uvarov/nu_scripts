# export def main [] {}

# Print the string colorfully with bells and whistles.
export def main [
    ...text_args
    --color (-c): any = 'default'
    --highlight_color (-h): any = 'green_bold'
    --frame_color (-r): any = 'dark_gray'
    --frame (-f): string = ' '  # A symbol (or a string) to frame text
    --before (-b): int = 0      # A number of new lines before text
    --after (-a): int = 1       # A number of new lines after text
    --echo (-e)                 # Echo text string instead of printing
    --keep_single_breaks        # Don't remove single line breaks
    --width (-w): int = 80      # The width of text to format it
] {
    let $width_safe = (
        term size
        | get columns
        | ($in // ($frame | str length))
        | $in - 1
        | [$in $width] | math min
        | [$in 1] | math max    # term size gives 0 in tests
    )

    def wrapline [
        line: string
    ] {
        if (($width == 0) or ($line | str length | $in <= $width_safe)) {
            return $line
        }

        let text = ($line | split chars)
        mut agg = []
        mut line_length = 0
        mut last_space_index = -1
        mut total_length = 0

        for i in $text {
            $line_length = ($line_length + 1)
            if $line_length > $width_safe {
                if $last_space_index != -1 {
                    # $agg = ($agg | update $last_space_index "\n")
                    $agg = ($agg | append [{index: $last_space_index char: "\n"}])
                    $line_length = $total_length - $last_space_index
                    $last_space_index = -1
                } else {
                    # $agg = ($agg | append "\n")
                    $agg = ($agg | append [{index: $last_space_index char: $"($i)\n"}])
                    $line_length = 0
                }
            }

            if $i == ' ' {
                $last_space_index = $total_length
            }
            # $agg = ($agg | append $i)
            $total_length = ($total_length + 1)
        }

        $agg
        | reduce -f $text {|i acc| $acc | update $i.index $i.char}
        | str join
    }

    def compactit [] {
        $in
        | if $keep_single_breaks {
            str replace -r -a '^[\t ]+' ''
        } else {
            str replace -r -a '(\n[\t ]*(\n[\t ]*)+)' '⏎'
            | str replace -r -a '\n?[\t ]+' ' '    # remove single line breaks used for code formatting
            | str replace -a '⏎' "\n\n"
        }
        | lines
        | each {|i| $i | str trim | wrapline $in}
        | str join "\n"
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
        | str join
        | $'(ansi $color)($in)(ansi reset)'
    }

    def frameit [] {
        let $text = $in;
        let $line = (
            ' '
            | fill -a r -w $width_safe -c $frame
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
        $text_args
        | str join ' '
        | compactit
        # | colorit
        | if $frame != ' ' {
            frameit
        } else {}
        | if $echo { } else { newlineit }
    )
}