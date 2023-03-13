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
        pueue add $"nu -c \"($command)\" --config \"($nu.config-path)\" --env-config \"($nu.env-path)\""
    )
    {"job_id": $job_id}
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
export def status () {
    pueue status --json
    | from json
    | get tasks
    | transpose -i status
    | flatten
    | flatten status
    | explore
}

# kill specific job
export def kill (id: int) {
    pueue kill $id
}

# clean job log
export def clean () {
    pueue clean
}
