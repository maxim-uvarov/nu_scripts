def 'fill non-exist' [
    tbl
    --value = null
] {
    let cols = ($tbl | par-each {|i| $i | columns} | uniq | reduce --fold {} {|i acc| $acc | merge {$i : $value}})
    
    $tbl | par-each {|i| $cols | merge $i}
}