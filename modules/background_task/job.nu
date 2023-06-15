# spawn task to run in the background
#
# please note that a fresh nushell is spawned to execute the given command
# So it doesn't inherit current scope's variables, custom commands, alias definition, except env variables which value can convert to string.
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

export def log [
    id: int   # id to fetch log
] {
    pueue log $id -f --json
    | from json
    | transpose -i info
    | flatten --all
    | flatten --all
    | flatten status
    | move output --before id
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
}

export def 'parse' [
] {
    $in 
    | par-each {|i| $i 
        | upsert created_at {|b| $b.created_at | into datetime} 
        | upsert start {|b| if $b.start != null {$b.start | into datetime}} 
        | upsert end {|b| if $b.end != null {$b.end | into datetime}} 
        | upsert duration {|b| if $b.end != $nothing {$b.end - $b.start}} 
        | upsert command {|b| $b.command | split row " --config \"" | get 0}
    } 
    | reject end 
    | move start duration --before command 
    | sort-by id
}

# get job running status
export def status_old () {
    pueue status --json
    | from json
    | get tasks
    | transpose -i status
    | flatten
    | flatten status
}

# kill specific job
export def kill (id: int) {
    pueue kill $id
}

# clean job log
export def clean () {
    pueue clean
}
