# Deploy-Scripts
Shell script templates for automating recurring push/pull/syncing tasks

## Use at your own risk! Always have backups ready.

Fill in the credentials in variables provided, comment/uncomment options, and run.

### Arguments:

`all` Files and Database

`db` Database only

`files` Files only

Sample usage:

`sh pull.sh all`

`sh deploy.sh db`

`sh deploy.sh files`

rsync options from: https://www.computerhope.com/unix/rsync.htm