def 'hist-save' [
    # count: int = 20
    --dir: string
] {
    let $dir = ($dir | default $"/Users/user/apps-files/github/nushell_playing/")
    let name = $"history(date now | date format '%Y%m%d-%H%M%S')"

    history -l
    | where session_id == (history session)
    | get command
    | save $"($dir)/($name).nu"

    print $"file saved ($dir)/($name).nu"

    code $"($dir)/($name).nu"
}

def 'hs' [
    filename?
    --dir: string
    --dont_open (-O)
    --up (-u): int = 0
    --all               # Save all history into .nu file
    --directory_hist # get history for a directory instead of session
] {
    let $path = (
        if ($dir == null) {
            [
                (pwd)
                "/Users/user/apps-files/github/nushell_playing/"
                'type your variant'
                'use gum'
            ]
            | input list 'choose directory'
            | if ($in | path exists) {} else {
                match $in {
                    'type your variant' => {input 'type your variant'},
                    'use gum' => {
                        gum file --directory (pwd)
                        | str trim -c (char nl)
                        | if ($in | path type) == 'file' {
                            path basename
                        } else {}
                    }
                }
            }
            | if ($in | path exists) {} else {
                error make {msg: $"the path ($in) doesn't exist"}
            }
        } else {}
        | path expand
    )
    let $session = (history session)
    let $hist_raw = (
        history -l
        | if $directory_hist {
            where cwd == (pwd)
        } else {
            where session_id == $session
        })

    let $name = (
        $filename
        | if ($in != null) {} else {
            [
                ($"history($session)"),
                'type your variant'
            ] | input list
            | if ($in == 'type your variant') {
                input 'type your variant: '
            } else {}
        }
    )

    let $filepath = ($path | path join $"($name).nu")

    let $hist = (
        | $hist_raw
        | get command
        | each {|i| $i | str replace -ar $';(char nl)\$.*? in-vd' ''}
    )

    let buffer = (
        if $up > 1 {
            $hist
            | last ($up + 1)
            | drop 1
        } else if $all {
            $hist
            | drop 1
        } else {
            $hist
            | filter {|i| ($i =~ '(^(let|def|export) )|#|\b(save|source|mkdir)\b')}
            | append "\n\n"
            | prepend $"#($name)"
        }
    )

    $buffer | save -a $filepath

    if not $dont_open {
        code -n $filepath
    }
}

def 'hs-line' [
    # count: int = 20
    --dir: string
    --open (-o)
] {
    let $dir = ($dir | default $"/Users/user/apps-files/github/nushell_playing/")
    let name = $"history(history session).nu"

    history -l
    | where session_id == (history session)
    | get command
    | last 2
    | first 1
    | save $"($dir)/($name).nu" -a

    # print $"file saved ($dir)/($name).nu"

    if $open {
        code $"($dir)/($name).nu"
    }
}

# def 'hist-save' [
#     count: int = 20
# ] {
#     let name = $"history(date now | date format '%Y%m%d-%H%M%S')"

#     history
#     | get command
#     | last $count
#     | save $"/Users/user/apps-files/github/nushell_playing/($name).nu"
# }
