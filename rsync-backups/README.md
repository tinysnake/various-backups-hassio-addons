# Home Assistant Add-On: Rsync Backups

## About

This add-on is capable syncing your backup files to remote server using rsync.

If your remote server don't have rsync daemon running, you can use ssh mode to sync your backup files instead.

It's recommended using this add-on along with the [Auto Backup Custom Component](https://github.com/jcwillox/hass-auto-backup)

By now, this add-on only support username and password authorization, public key authorization is not supported yet.