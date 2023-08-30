# > [{a: 1} {b: 2}] | to nuon
# [{a: 1}, {b: 2}]
#
# > [{a: 1} {b: 2}] | fill non-exist | to nuon
# [[a, b]; [1, null], [null, 2]]
def fill non-exist [ tbl?: any --value: nothing ] {
    let tbl = ($in | default $tbl)
    let cols = ($tbl | each {|i| $i | columns} | flatten | uniq | reduce --fold {} {|i acc| $acc | merge {$i : $value}})

    $tbl | each {|i| $cols | merge $i}
}