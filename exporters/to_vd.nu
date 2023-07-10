# Pipe input data to VisiData in CSV or JSON format. 
# The suitable format is detected automatically. 
# If VisiData produces STDOUT, it will be assigned to $env.vd_temp.
#
# Examples:
# > history | to vd
def-env 'to vd' [] {
    let $obj = $in

    def is_flat [
        data_type_description: string
    ] {
        (
            ($data_type_description | str starts-with 'table') and
            ($data_type_description | find -r ': (table|record|list)' | is-empty)
        )
    }

    let $data_type_description = ($obj | describe)
    
    if $data_type_description == 'dataframe' {
        $obj | dfr into-df | dfr into-nu 
    } else { $obj } 
    | if (is_flat $data_type_description) {
        to csv | vd --filetype csv
    } else {
        to json | vd --filetype json 
    }
    | from tsv  # vd will output tsv if you quit with `ctrl + shift + q`
    | if ($in != null) {
        $env.vd_temp = $in;
        $in
    }
}