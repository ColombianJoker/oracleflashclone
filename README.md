# oracleflashclone

Scripts to clone complete instance Oracle databases on IBM FlashSystems

## oraclone

This scripts after loading all auxiliary functions connects to an IBM FlashSystems and creates a new snapshot set from a volumegroup fully populated with volumes for Oracle databases mapped to a set of AIX nodes in a cluster. Then maps the volumes to the current AIX system, detects them and tries to enable then for Oracle database server use

### Dependencies

- It needs to run under a user belonging to the `system` AIX group (**root**), better to use root.
- It needs a configuration file that includes the variables

```sh

export DEBUG=true|false
export STORAGEDEF=name of storage in ~/.ssh/config
export VOLUMEGROUP=flashsystem volume group to clone
export VOLUMEPREFIX=prefix of the names of the volumes in the volumegroup
export HDISKPREFX=prefix of the names of the hdisk devices
export STORAGEHOSTNAME=client host name of the server in flashsystem

# STORAGEHOSTNAME is optional, if not given it will use the hostname of the
#  AIX server
#
```

---

(c) Ramón Barrios Láscar, 2026
