# Pipe input data to VisiData in CSV or JSON format. 
# The suitable format is detected automatically. 
# If VisiData produces STDOUT, it will be assigned to $env.vd_temp.
#
# Examples:
# > history | to vd
def-env 'to vd' [] {
    let $obj = $in

    # > [{a: b, c: d}] | describe | is_flat
    # true
    # > [{a: {c: d}, b: e}] | describe | is_flat
    # false
    def is_flat [] {
        let $type_description = ($in | describe)
        (
            ($type_description | str starts-with 'table') and
            ($type_description | find -r ': (table|record|list)' | is-empty)
        )
    }

    (
        $obj 
        | if ($obj | describe | $in == 'dataframe') {
            dfr into-df | dfr into-nu 
        } else { } 
        | if ($in | is_flat) {
            to csv | vd --filetype csv
        } else {
            to json -r | vd --filetype json 
        }
        | from tsv  # vd will output tsv if you quit with `ctrl + shift + q`
        | if ($in != null) {
            $env.vd_temp = $in;
            $in
        }
    )
}