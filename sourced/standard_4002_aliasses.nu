alias ':q' = exit
alias timeitt = commandline $"timeit {(history | last 2 | first | get command)}"
alias profilee = commandline $"profile {||(history | last 2 | first | get command)}"
