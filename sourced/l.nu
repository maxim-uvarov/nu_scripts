# let args = ['ls', '-a']
export def l [
    ...args
] {
    let args = ($args | str join " ")
    ^nu -c $args --config $nu.config-path --env-config $nu.env-path
}