use /Users/user/git/nushell-kv/kv.nu

# Open data in VisiData🔥
#
# The suitable format is detected automatically.
# If VisiData produces STDOUT, it will be assigned to $env.vd_temp.n
#
# Examples:
# > history | in-vd
def-env 'in-vd' [
    --dont_strip_ansi_codes (-S) # ansi codes are stripped by default, this option disables stripping ansi codes.
    --json (-j)     # force to use json for piping data in-vd
    --csv (-c)      # force to use csv for piping data in-vd
] {
    let $obj = $in

    # > [{a: b, c: d}] | is_flat
    # true
    # > [{a: {c: d}, b: e}] | is_flat
    # false
    def is_flat [] {
        $in
        | describe
        | find -r '^table(?!.*: (table|record|list))'
        | is-empty
        | not $in
    }

    def-env set-temp-env [
        value
    ] {
        let $vd_temp_index = (
            $env.vd_temp?
            | default {}
            | columns
            | length
        )

        $env.vd_temp = (
            if $vd_temp_index == 0 {
                {'a1': $value}
            } else {
                $env.vd_temp
                # integers in record keys are problematic, so we use 'a' prefix
                | upsert $'a($vd_temp_index + 1)' ( $value )
            }
        )

        let $val_length = ($value | length)

        if $val_length > 6 {
            print $'The (ansi green)$env.vd_temp.($env.vd_temp | columns | last)(ansi reset) variable is set. It has ($val_length) rows.'
            print 'The first 3 and the last 3 of them are shown below.'

            $value | first 3
            | append ($value | columns | reduce -f {} {|col acc| $acc | merge {$col : '*'}})
            | append ($value | last 3)
        } else {
            $value
        }
    }

    $obj
    | if ($obj | describe | $in == 'dataframe') {
        dfr into-nu
        | reject index
    } else { }
    | if ($csv) or (($in | is_flat) and (not $json)) {
        to csv
        | if not $dont_strip_ansi_codes {
            ansi strip
        } else { }
        | vd --save-filetype json --filetype csv -o -
    } else {
        to json -r
        | if not $dont_strip_ansi_codes {
            ansi strip
        } else { }
        | vd --save-filetype json --filetype json -o -
    }
    | from json  # vd will output the final sheet `ctrl + shift + q`
    | if ($in != null) {
        kv set vd
    }
}

# Open nushell commands history in visidata
export def 'history-in-vd' [
    --entries: int = 5000 # the number of last entries to work with
    --all                   # return all the history
    --session (-s)  # show only entries from session
] {
    $in
    | default (history -l)
    | if $session {
        where session_id == (history session)
    } else if ($entries == 0) or $all {} else {
        last $entries
    }
    | reverse
    | upsert duration_s {|i| $i.duration | into int | $in / (10 ** 9)}
    | reject item_id duration hostname
    | move start_timestamp --after command
    | upsert pipes {|i| $i.command | split row -r '\s\|\s' | length}
    | to csv
    | vd --save-filetype csv --filetype csv -o -
    | if ($in == null) { return } else { }
    | from csv
    | get command
    | reverse
    | str join $';(char nl)'
    | str replace -r ';.+?\| in-vd;' ';'
    | commandline $in
}