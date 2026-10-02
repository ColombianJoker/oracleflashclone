export DEBUG=false
export STORAGEDEF=colxvfs5k
export VOLUMEGROUP=oradb
export VOLUMEPREFIX=dbs_
export HDISKPREFIX=o
export CLUSTERNODES="192.168.55.21 192.168.55.22"
export CLUSTERPORTS="1521 1525"


### --------- --------- --------- ---------
Loaded () {
    printf "$PRGNAME: default_configuration loaded.\n" >&2
}
