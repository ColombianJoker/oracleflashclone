#!/usr/bin/env ksh93

ShowSyntax () {
    printf "$PRGNAME creates clones of databases on FlashSystems\n"
    printf "Syntax:\n"
    printf "  $PRGNAME [ do ] config_file\n"
    printf "  $PRGNAME\n"
    printf "\n"
    printf "Without arguments shows this help\n"
    printf "With a config_file, shows the configuration parameters (variables)\n"
    printf "With 'do' and a configuration file, runs with the parameters\n"
}

PrintConfiguration () {
  # Show configuration
  printf "$PRGNAME configuration:\n"
  printf "  DEBUG=$DEBUG\n"
  printf "  STORAGEDEF=$STORAGEDEF\n"
  printf "  VOLUMEGROUP=$VOLUMEGROUP\n"
  printf "  SOURCECLUSTER=$SOURCECLUSTER\n"
  printf "  VOLUMEPREFIX=$VOLUMEPREFIX\n"
  printf "  HDISKPREFIX=$HDISKPREFIX\n"
  printf "  CLUSTERNODES=$CLUSTERNODES\n"
  printf "  CLUSTERPORTS=$CLUSTERPORTS\n"
  printf "  RAWOWNER=$RAWOWNER\n"
}

### --------- --------- --------- ---------
Loaded () {
    printf "$PRGNAME: help functions loaded.\n" >&2
}
