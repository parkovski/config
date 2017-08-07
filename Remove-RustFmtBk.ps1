rg --files --no-ignore-vcs . | where {$_.EndsWith('.bk')} | rm
