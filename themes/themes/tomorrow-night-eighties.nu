export def main [] { return {
    separator: "#cccccc"
    leading_trailing_space_bg: { attr: "n" }
    header: { fg: "#99cc99" attr: "b" }
    empty: "#6699cc"
    bool: {|| if $in { "#66cccc" } else { "light_gray" } }
    int: "#cccccc"
    filesize: {|e|
        if $e == 0b {
            "#cccccc"
        } else if $e < 1mb {
            "#66cccc"
        } else {{ fg: "#6699cc" }}
    }
    duration: "#cccccc"
    date: {|| (date now) - $in |
        if $in < 1hr {
            { fg: "#f2777a" attr: "b" }
        } else if $in < 6hr {
            "#f2777a"
        } else if $in < 1day {
            "#ffcc66"
        } else if $in < 3day {
            "#99cc99"
        } else if $in < 1wk {
            { fg: "#99cc99" attr: "b" }
        } else if $in < 6wk {
            "#66cccc"
        } else if $in < 52wk {
            "#6699cc"
        } else { "dark_gray" }
    }
    range: "#cccccc"
    float: "#cccccc"
    string: "#cccccc"
    nothing: "#cccccc"
    binary: "#cccccc"
    cellpath: "#cccccc"
    row_index: { fg: "#99cc99" attr: "b" }
    record: "#cccccc"
    list: "#cccccc"
    block: "#cccccc"
    hints: "dark_gray"
    search_result: { fg: "#f2777a" bg: "#cccccc" }

    shape_and: { fg: "#cc99cc" attr: "b" }
    shape_binary: { fg: "#cc99cc" attr: "b" }
    shape_block: { fg: "#6699cc" attr: "b" }
    shape_bool: "#66cccc"
    shape_custom: "#99cc99"
    shape_datetime: { fg: "#66cccc" attr: "b" }
    shape_directory: "#66cccc"
    shape_external: "#66cccc"
    shape_externalarg: { fg: "#99cc99" attr: "b" }
    shape_filepath: "#66cccc"
    shape_flag: { fg: "#6699cc" attr: "b" }
    shape_float: { fg: "#cc99cc" attr: "b" }
    shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: "b" }
    shape_globpattern: { fg: "#66cccc" attr: "b" }
    shape_int: { fg: "#cc99cc" attr: "b" }
    shape_internalcall: { fg: "#66cccc" attr: "b" }
    shape_list: { fg: "#66cccc" attr: "b" }
    shape_literal: "#6699cc"
    shape_match_pattern: "#99cc99"
    shape_matching_brackets: { attr: "u" }
    shape_nothing: "#66cccc"
    shape_operator: "#ffcc66"
    shape_or: { fg: "#cc99cc" attr: "b" }
    shape_pipe: { fg: "#cc99cc" attr: "b" }
    shape_range: { fg: "#ffcc66" attr: "b" }
    shape_record: { fg: "#66cccc" attr: "b" }
    shape_redirection: { fg: "#cc99cc" attr: "b" }
    shape_signature: { fg: "#99cc99" attr: "b" }
    shape_string: "#99cc99"
    shape_string_interpolation: { fg: "#66cccc" attr: "b" }
    shape_table: { fg: "#6699cc" attr: "b" }
    shape_variable: "#cc99cc"

    background: "#2d2d2d"
    foreground: "#cccccc"
    cursor: "#cccccc"
}}