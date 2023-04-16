# Frequently used Nu commands
def history-stats2 [
    --verbose (-v): bool
    --hours_in_group: int = 4     # When used sql history storage, commands are grouped by number of hours to reduce outliers
] {
    def hist_from_sql [
        hours_in_group
    ] {
        print $"You use sqlite as a history storage. So commands in your history are grouped by ($hours_in_group) hours."
        print "If the command was used many times per group in final stats it will be counted only once."
        print "You can change the number of hours in a group by setting a parameter `--hours_in_group`."

        (
            $nu.history-path 
            | open 
            | get history 
            | where exit_status == 0
            | select start_timestamp command_line
            | upsert rounded_timestamp {
                |it| $it.start_timestamp // (60 * 60 * $hours_in_group)
            } | select rounded_timestamp command_line 
            | group-by rounded_timestamp 
            | values 
            | each {
                |i| $i 
                | get command_line 
                | str join " "
            } 
        )
}

    def hist_from_txt [] {
        history | get command
    }

    let hist = (
        if ($nu.history-path | path parse | get extension | $in == sqlite3) {
            (hist_from_sql $hours_in_group)
        } else {
            (hist_from_txt)
        }
    )

    let freq = (
        help commands 
        | select name command_type
        | par-each {
            |i| $i 
            | upsert count_with_subcommands {
                |i| $hist 
                | find -r $'\b($i.name)\b' 
                | length
            }
        } | where count_with_subcommands > 0
        | sort-by count_with_subcommands -r 
    )

    let freq_no_subcommands = (
        $freq 
        | par-each {
            |i| $i 
            | upsert count {
                |it| $freq 
                | where name =~ $'\b($i.name)\b' 
                | get count_with_subcommands
                | math sum 
                | ($i.count_with_subcommands * 2) - $in
            } 
        } | sort-by count -r 
        | filter {|i| ($i.command_type == 'builtin') or ($i.command_type == 'keyword')}
        | reject command_type count_with_subcommands
        | where count >= 10
    )

    if ($verbose) {
        let total_cmds = (history | length)
        let unique_cmds = (history | get command | uniq | length)

        print $"(ansi green)Total commands in history:(ansi reset) ($total_cmds)"
        print $"(ansi green)Unique commands:(ansi reset) ($unique_cmds)"
        print ""
        print $"(ansi green)Top ($summary)(ansi reset) most used commands:"
    }

    let filename = $"frequent-commands-($nu.history-path | path parse | get extension).csv"
    $freq_no_subcommands | save -f $filename

    print $"($filename) was written. Please share it in the thread:"
    echo $freq_no_subcommands
}

