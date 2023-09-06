export def main [] {}

export def 'take' [
    name: string
    --persistent
] {
    {name: $name, value: $in, ts: (date now)}
    | if $persistent {
        upsert persistent true
    } else {}
    | to json -r
    | $'($in)(char nl)'
    | save -a -r ~/.note.jsonl
}

export def 'get' [
    name: string@'nu-complete-notes-names'
] {
    open-notes | where name == $name | get 0.value
}

export def 'clean' [] {
    open-notes
    | where name.persistent? != true
    | save -a -r ~/.note.jsonl
}

def 'nu-complete-notes-names' [] {
    open-notes | get name
}

def 'open-notes' [] {
    open ~/.note.jsonl -r | from json -o
}