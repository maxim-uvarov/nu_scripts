# create directory and cd into it.
use std clip

def-env md [dir] {
  let dir = ($dir | into string | path expand)
  mkdir $dir
  cd $dir
}

def is-cid [particle: string] {
    ($particle =~ '^Qm\w{44}$')
}

def is-neuron [particle: string] {
    ($particle =~ '^bostrom1\w{38}$')
}

def is-connected []  {
    (do -i {http get https://duckduckgo.com/} | describe) == 'raw input'
}

def 'now' [
    --pretty (-P)
] {
    if $pretty {
        date now | format date '%Y-%m-%d-%H:%M:%S'
    } else {
        date now | format date '%Y%m%d-%H%M%S'
    }
}

def 'backup' [
    filename
    --to: string
] {
    let filename = ($filename | path expand)
    let basename1 = ($filename | path basename)
    let filename1 = ($filename | path parse)

    let to_folder = if $to == null {
        (pwd)
    } else {
        $to | path expand
    }

    if (
        $filename
        | path exists
    ) {
        cp $filename $"($to_folder)/($filename1.stem)(now).($filename1.extension)" -v -r
        # print $"Previous version of ($filename) is backed up to ($path2)"
    } else {
        print $"($filename) does not exist"
    }
}

export def 'pu-add' [
    command: string
] {
    pueue add -p $"nu -c \"($command)\" --config \"($nu.config-path)\" --env-config \"($nu.env-path)\""
}

export def 'beep' [] {
    say done
}

def f [] { start . }

def 'py-graph-update' [] {
    timeit {
            /Users/user/miniconda3/envs/cyber311/bin/python /Users/user/apps-files/github/bostrom-journal-py2/cyber_localgraph_update.py
        }
}

def 'py-graph-contract-update' [] {
    timeit {
            /Users/user/miniconda3/envs/cyber311/bin/python /Users/user/apps-files/github/bostrom-journal-py2/graph_append_contract_cyberlinks.py
    }
}

def 'gp' [
    ...rest: string@"nu-complete gpt completions"
] {
    /Users/user/miniconda3/envs/openai/bin/python /Users/user/apps-files/github/gpt-cli/gpt.py $rest
}


def "nu-complete gpt completions" [] {
    open ~/.gptrc | from yaml | get assistants | columns
}

# def-env "reload config" [] {
#     source '/Users/user/Library/Application Support/nushell/env.nu'; source '/Users/user/Library/Application Support/nushell/config.nu'
# }

def 'mygit log' [
    --message (-m): string
] {
    let $message = ($message | default (date now | format date "%Y-%m-%d"))

    glob $'("~" | path expand)/.*' --no-dir
    | each {|i| cp $i ('~/.config/dot_home_dir' | path expand)}

    [
        '~/Library/Application Support/nushell'
        '~/apps-files/github/nu_scripts/'
        '~/.config/'
        '~/.visidata/'
    ] | path expand
    | each { |dir|
        print $dir;
        cd $dir;
        git add --all
        git commit -a -m $message
    }
}

def 'repeat' [
    from_command?: string@'nu-complete-history-commands'
    to_command?: string@'nu-complete-history-commands'
] {
    let $hist = (history | get command | last 50 | drop 1)
    let $from_command = (
        try {
            $hist
            | reverse
            | get (
                $from_command
                | into int
                | $in
            )
        } catch {$from_command}
    )
    let $hist = ($hist | reverse | take until {|i| $i == $from_command} | append $from_command | reverse)
    let $hist = (
        if $to_command == null {
            $hist
        } else {
            $hist | skip while {|i| $i == $to_command}
        }
    )

    commandline ($hist | str join '; ' | $in + " #repeat_fn ")
}

def "nu-complete-history-commands" [] {
    history | last 50 | drop 1 | get command | reverse | each {|i| $"`($i)`"}
}

# https://gist.github.com/TrMen/d5bc8dc41644c7e3d9ba4a9611d3c38b
def whatnow [] {
    let in_type = ($in | describe)

    let matched_types = (if $in_type =~ "list<.*>" {
        let list_value_type = ($in_type | parse -r "list<(?P<inner_type>.+)>" | get inner_type | get 0)
        ['list<any>', $in_type, $list_value_type]
    } else if $in_type =~ "record<.*>" {
        ["record"]
    } else if $in_type =~ "table<.*>" {
        ["table"]
    } else {
        [$in_type]
    } | uniq)

    let commands = (
        $nu.scope.commands
        | select name signatures usage
        | update signatures { |item| $item.signatures | transpose | get column1 }
        | rename name signature usage
        | flatten
    )

    let matching_commands = (
        $commands
        # TODO: This assumes that input is at position 0, but using a nested where here is extremely
        # slow for some reason, even though we're only iterating over ~500 records.
        | where { |command| ($command.signature.0.syntax_shape) in $matched_types }
    )

    let commands_with_simplified_signatures = ($matching_commands | par-each { |command|
       let input = ($command.signature | where parameter_type == input | get 0)
       let output = ($command.signature | where parameter_type == output | get 0)
       let positionals = ($command.signature | where parameter_type == positional)

       let positional_string = ($positionals.syntax_shape | each {|shape| $" <($shape)>"} | str join)

       {name: $command.name, signature: $"<($input.syntax_shape)> | ($command.name) ($positional_string) -> ($output.syntax_shape)", usage: $command.usage}
    })

    $commands_with_simplified_signatures | sort-by signature name
}

# # https://discord.com/channels/601130461678272522/1098446929555374101/1098718686661058682
# def _try_flag [command: string, flag: string] {
#     try {
#         let exit = (^$command $flag | complete | get exit_code)
#         if $exit != 0 {
#             false
#         }
#         true
#     } catch {
#         false
#     }
# }

# def _try_builtin [command: string] {
#     try {
#         help $command
#         return true
#     } catch {
#         return false
#     }
# }

# let flags = ["--help" "-h"]
# let flags_length = ($flags | length)
# let fall_back = "tldr"

# def _help [command: string = "help"] {
#     if ($command == "help") {
#         return (help)
#     }

#     let builtin = if not ($command | str starts-with "^") {
#         _try_builtin $command
#     } else {
#         false
#     }
#     if not $builtin {
#         mut command = $command
#         if ($command | str starts-with "^") {
#             $command = ($command | str substring 1..)
#         }
#         mut index = 0
#         while $index < $flags_length {
#             if (_try_flag $command ($flags | get $index)) {
#                 break
#             }
#             $index = $index + 1
#         }
#         if $index == $flags_length {
#             ^$fall_back $command
#         } else {
#             ^$command ($flags | get $index)
#         }
#     } else {
#         help $command
#     }
# }
# alias help = _help

export def commit_type [] {
    {
        feat: "⚡"
        fix: '🐛'
        docs: "📚"
        style: "💎"
        refactor: "🔨"
        test: "🚨"
        chore: "🧹"
        revert: "⏪"
        WIP: "🚧"
        release: "📦"

    }
}

export def "git icommit" [] {
    let prefix = $"(ansi red_bold)>(ansi reset)"
    let kind = (commit_type | columns | input list $"($prefix) Commit Kind: ")
    let msg = (input $"($prefix) Commit Message: ")


   git commit -m $"($kind) (commit_type | get $kind): ($msg)"

}
