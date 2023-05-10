# create directory and cd into it.
def-env md [dir] {
  let dir = ($dir | path expand | into string)
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

def make_default_folders_fn [] {
    mkdir $"($env.cyfolder)/temp/"
    mkdir $"($env.cyfolder)/backups/"
    mkdir $"($env.cyfolder)/config/"
    mkdir $"($env.cyfolder)/cache/"
    mkdir $"($env.cyfolder)/cache/search/"
    mkdir $"($env.cy.ipfs-files-folder)/"
    mkdir $"($env.cyfolder)/cache/queue/"
    mkdir $"($env.cyfolder)/cache/cli_out/"
}

def 'now' [
    --pretty (-P)
] {
    if $pretty {
        date now | date format '%Y-%m-%d-%H:%M:%S'
    } else {
        date now | date format '%Y%m%d-%H%M%S'
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
        cp $filename $"($to_folder)/($filename1.stem)(now).($filename1.extension)" -v
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

def 'fill non-exist' [
    tbl?
    --value = null
] {
    let tbl = ($in | default $tbl)
    let cols = ($tbl | each {|i| $i | columns} | flatten | uniq | reduce --fold {} {|i acc| $acc | merge {$i : $value}})
    
    $tbl | each {|i| $cols | merge $i}
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
    folder?: string@'nu-complete-my-folders-for-git'
    --message (-m): string
] {
    let $message = ($message | default (date now | date format "%Y-%m-%d"))
    cd $folder; 
    git commit -a -m $message 
}

def "nu-complete-my-folders-for-git" [] {
    [
        '~/Library/Application Support/nushell'
        '~/apps-files/github/nu_scripts/'
        '~/.config/'
    ] | each {|i| $"'($i)'"}
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
    let $hist = ($hist | reverse | take until {|i| $i == $from_command} | reverse)
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
