#!/usr/bin/env nu

def "nu-complete help categories" [] {
    help commands | get category | uniq
}

def hc [category?: string@"nu-complete help categories"] {
    help commands 
    | select name category usage 
    | move usage --after name 
    | where category =~ $category 
}