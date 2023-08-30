#   
# The suitable format is detected automatically. 
# If VisiData produces STDOUT, it will be assigned to $env.vd_temp.n
#
# Examples:
# > history | to vd
def-env 'to vd' [
    --dont_strip_ansi_codes (-S) # ansi codes are stripped by default, this option disables stripping ansi codes.
    --json (-j)     # force to use json
    --csv (-c)      # force to use csv 
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
        $value
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
        | vd --filetype csv
    } else {
        to json -r 
        | if not $dont_strip_ansi_codes {
            ansi strip
        } else { } 
        | vd --filetype json 
    }
    | from tsv  # vd will output tsv if you quit with `ctrl + shift + q`
    | if ($in != null) {
        set-temp-env $in
    }
}