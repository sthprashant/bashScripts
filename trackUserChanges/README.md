## Overview
- A script that tracks the user changes on Linux (currently tested on centOs)
- Gets a list of users from `/etc/passwd`
- Creates a MD5 hash of the output and stores the hash into a file
- Next time the script runs, it compares the older hash and new hash to determine changes in the /etc/passwd file

To run the script periodically, crontab can be used `crontab -e` 
	- [crontab expression guide](https://crontab.guru)
