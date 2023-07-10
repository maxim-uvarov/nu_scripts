#!/usr/bin/env nu

http get https://raw.githubusercontent.com/nushell/nushell/main/crates/nu-utils/src/sample_config/default_config.nu | save default_config.nu
code --diff default_config.nu $nu.config-path
http get https://raw.githubusercontent.com/nushell/nushell/main/crates/nu-utils/src/sample_config/default_env.nu | save default_env.nu
code --diff default_env.nu $nu.env-path

[yes no] 
| input list 'confirm removal' 
| if $in == yes {rm default_config.nu default_env.nu -f}