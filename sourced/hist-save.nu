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
    --all
] {
    let $dir = ($dir | default $"/Users/user/apps-files/github/nushell_playing/")

    let hist_raw = (
        history -l | where session_id == (history session)
    )

    let $session = ($hist_raw | last | get session_id )

    let name = ($filename | default ($"history($session)"))

    let $hist = (
        | $hist_raw
        | where session_id == ($session)
        | get command
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
            | filter {|i| ($i =~ "^let ") or ($i =~ "#") or ($i =~ "^def") or ($i =~ '\bsave\b') or ($i =~ 'source')}
            | append "\n\n"
            | prepend $"#($name)"
        }
    )

        $buffer | save $"($dir)/($name).nu" -a

    # print $"file saved ($dir)/($name).nu"

    if not $dont_open {
        code -n $"($dir | path join $name).nu"
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
