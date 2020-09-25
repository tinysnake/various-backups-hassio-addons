# Home Assistant Add-On: Rsync Backups

## After Installation

This add-on don't need to run constantly in the background, it will shut it self down when the backup process is done. So we need to make sure the `Start on boot` option is disabled in the add-on info tab.

## Configuration

Configuration is like this:

```
server: 192.168.1.2
username: rsyncuser
password: rsyncpass
path: /path/to/the/snapshots
filters: []
delete: false
ssh: false
no_perm: false
```

### Option `server`

The target server name, it can be a domain name or a ip address

### Option `username`

The rsync username or ssh username

### Option `password`

The corresponding password to the username

### Option `path`

The target path of the server that we are syncing to.

If we use ssh as the syncing method, we often enter something like `/mnt/hdd1/hass-backups/`

If we are syncing to rsync server, we often enter the module name first and follow with a folder name like `my-rsync-module/hass-backups/`

### Option `filters`

If you want to filter something in or out, you can write rsync filter rule in this field, for example:

```
filters:
  - "+ *.txt"
  - "- somedir/"
```

### Option `delete`

If you set this option true, it means any file that does not exist in your /backup folder will be deleted.

It's useful if you want to keep the source folder and destination folder the same.

### Option `ssh`

ssh is the more versatile way to log into your remote server, but exposing your system username and password to this page is creating a security risk in some degree, especially the root user.

So I highly recommend you to run rsync daemon on your remote server, that way will reduce the security risk to minimum(as long as you don't set the username and password to match the system one).

### Option `on_perm`

This option is short for `no permission`, it is useful when the destination path of the file system doesn't support Unix-style permissions, like `FAT` and `exFat`.


## Combine me with Auto Backup Custom Component

[Auto Backup](https://github.com/jcwillox/hass-auto-backup) is a Custom Component, you can install it traditional way or the [HACS](https://hacs.xyz/) way.

After install and proper configuration, your Home assistant will have some services starts with `auto_backup`.

Now we can create an automation to run this add-on right after auto backup is complete.

```
- alias: "rsync the newly created snapshots"
  trigger:
    platform: event
    event_type: auto_backup.snapshot_successful
  action:
    service: hassio.addon_start
    data:
      addon: rsync_backups
```

## Support

open an issue on my [Github Repo](https://github.com/tinysnake/various-backups-hassio-addons/issues)!

