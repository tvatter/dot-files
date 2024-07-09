# Useful commands

Starting this far too late, but here it goes

```bash
code --list-extensions | sed 's/^/    "/' | sed 's/$/",/' | sed '$ s/,$//' | sed '1s/^/[/' | sed '$s/$/\n]/'
```
