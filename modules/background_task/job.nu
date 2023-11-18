# spawn task to run in the background
#
# please note that a fresh nushell is spawned to execute the given command
# So it doesn't inherit current scope's variables, custom commands, alias definition, except env variables which value can convert to string.
#
# Note that the closure to spawn can't take arguments.  And it only supports something like this: { echo 3 }, it have no parameter list.
#
# e.g:
# spawn { echo 3 }
export def spawn [
    command: string
] {
    let job_id = (
        pueue add -p $"nu -c \"($command)\" --config \"($nu.config-path)\" --env-config \"($nu.env-path)\""
    )
}

export def spawn-old [
    command: closure   # the command to spawn
    --label(-l): string    # the label of comand
    --group(-g): string    # the group name to spawn
] {
    let config_path = $nu.config-path
    let env_path = $nu.env-path
    let source_code = (view source $command | str trim -l -c '{' | str trim -r -c '}')
    mut args = [
        $"nu --config \"($config_path)\" --env-config \"($env_path)\" -c '($source_code)'",
    ]
    if $label != null {
        $args = ($args | prepend ["--label", $label])
    }
    if $group != null {
        $args = ($args | prepend ["--group", $group])
    }
    let job_id = (pueue add -p $args)

    {"job_id": $job_id}
}

export def log [
    id: int = -1   # id to fetch log
] {
    if $id == -1 {
        status | last | get id
    } else { $id }
    | pueue log $in -f --json
    | from json
    | transpose -i info
    | flatten --all
    | flatten --all
    | flatten status
    | move output --before id
}

# get job's stdout.
export def output [
    id: int   # id to fetch job's stdout
] {
    log $id | get output.0
}

# get job running status
export def status [
    --last = 0
] {
    pueue status -j
    | from json
    | get tasks
    | values
    | reject envs enqueued_at original_command
    | select status command ($in | columns)
    | upsert status {|i| if ($i.status | describe | str starts-with 'record') {$i.status | get done} else {$i.status}}
    | upsert command {|i| $i.command | str replace -r ' --config.*' ''}
}

export def 'parse' [
] {
    $in
    | par-each {|i| $i
        | upsert created_at {|b| $b.created_at | into datetime}
        | upsert start {|b| if $b.start != null {$b.start | into datetime}}
        | upsert end {|b| if $b.end != null {$b.end | into datetime}}
        | upsert duration {|b| if $b.end != null {$b.end - $b.start}}
        | upsert command {|b| $b.command | split row " --config \"" | get 0}
    }
    | reject end
    | move start duration --before command
    | sort-by id
}

# get job running status
export def status_old [
    pueue status --json
    | from json
    | get tasks
    | transpose -i status
    | flatten
    | flatten status
    --detailed(-d)   # need to get detailed stauts?
] {
    let output = (
        pueue status --json
        | from json
        | get tasks
        | transpose -i status
        | flatten
        | flatten status
    )

    if not $detailed {
        $output | select id label group Done? status? start? end?
    } else {
        $output
    }
}

# kill specific job
export def kill (id: int) {
    pueue kill $id
}

# clean job log
export def clean () {
    pueue clean
}
