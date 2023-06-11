#!/usr/bin/env nu

def wa [...input: string] {
    let APPID = (open /Users/user/apps-files/github/nu_scripts/helpers/.wa-secret.nu) # Get one at https://products.wolframalpha.com/api/
    let question_string = ([[i]; [($input | str join ' ')]] | encode base64)
    let url = (["https://api.wolframalpha.com/v1/result?appid=", $APPID, "&units=metric&", $question_string] | str join "")
    http get $url
}