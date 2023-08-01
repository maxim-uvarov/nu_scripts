# Pipe input data to VisiData in CSV or JSON format. 
# The suitable format is detected automatically. 
# If VisiData produces STDOUT, it will be assigned to $env.vd_temp.
#
# Examples:
# > history | to vd
def-env 'to vd' [
    --ansi_strip (-s)
    --json (-j)
    --csv (-c)
    --lines_for_detection = 100
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

    (
        $obj 
        | if ($obj | describe | $in == 'dataframe') {
            dfr into-df | dfr into-nu 
        } else { } 
        | if ($csv) or (($in | is_flat) and (not $json)) {
            to csv
            | if $ansi_strip {
                ansi strip
            } else { } 
            | vd --filetype csv
        } else {
            to json -r 
            | if $ansi_strip {
                ansi strip
            } else { } 
            | vd --filetype json 
        }
        | from tsv  # vd will output tsv if you quit with `ctrl + shift + q`
        | if ($in != null) {
            $env.vd_temp = $in;
            $in
        }
    )
}