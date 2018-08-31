#!/bin/bash

# Rescan shares (verbose, we have so many shares it's worth being able to debug if it hangs)
muscan --config "/root/.museekd/config.xml" -v -r

# Reload the museek daemon's shares once the SQLITE DB has been built
museekcontrol --password museek --reloadshares

## Example to share(s) via command line (note the --noscan at the end won't scan for files till this cron runs... Remove if you want to scan for files right away)
# muscan --config "/root/.museekd/config.xml" --share "/movies_tv" --noscan
