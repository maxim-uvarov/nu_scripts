#!/usr/bin/env nu

cd /Users/user/apps-files/github/nushell/crates/nu-utils/src/sample_config/
git pull origin main --rebase
git tag | lines | sort -n | last 2 | first | git checkout $in

# http get https://raw.githubusercontent.com/nushell/nushell/main/crates/nu-utils/src/sample_config/default_config.nu | save default_config.nu -f
code --diff default_config.nu $nu.config-path
# http get https://raw.githubusercontent.com/nushell/nushell/main/crates/nu-utils/src/sample_config/default_env.nu | save default_env.nu -f
code --diff default_env.nu $nu.env-path

# [yes no]
# | input list 'confirm removal'
# | if $in == yes {rm default_config.nu default_env.nu -f}
