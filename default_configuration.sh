export DEBUG=false
export STORAGEDEF=colxvfs5k
export VOLUMEGROUP=oradb
export SOURCECLUSTER=ORADBP
export VOLUMEPREFIX=dbs_
export HDISKPREFIX=co
export CLUSTERNODES="192.168.55.21 192.168.55.22"
export CLUSTERPORTS="1521 1525"
export LUNDELTA=10
export RAWMODE="ug=rw,o-rwx"
export RAWOWNER="crccuora:oinstall"

### --------- --------- --------- ---------
Loaded () {
    printf "$PRGNAME: default_configuration loaded.\n" >&2
}
