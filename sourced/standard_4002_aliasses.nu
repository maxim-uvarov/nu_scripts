alias ':q' = exit
alias timeitt = commandline edit -r $"timeit {(history | last 2 | first | get command)}"
alias profilee = commandline edit -r $"profile {||(history | last 2 | first | get command)}"
alias lg = lazygit
