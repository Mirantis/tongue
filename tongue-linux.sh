#!/bin/bash
# declare variables and get parameters
RED='\033[0;31m' # Red color
NC='\033[0m'     # No Color
DATE=$(date +"%d-%m-%Y-%H-%M-%S")
FILE=html
export LESSCHARSET="utf-8"
#LESS="bat -pf --theme=Dracula --pager 'less -x4RFWs'"
#LESS="less -R -F -X -I"
LESS1="less -x4RFWs"
LESS2="less -F -X -R"
GREP="grep --color=auto"
#GREP="/opt/homebrew/bin/rg --color=auto"
RG='rg --encoding=UTF-8 --pretty -thtml'

CALIBRE=
CEPH=
CLOUDINIT=
KERNEL=
KUBERNETES=
OPENSTACK=
RABBITMQ=
HELM=
SYSTEMD=
DOCKERENTERPRISE=
UBUNTU=
PROMETHEUS=
CALICO=
TUNGSTEN=
K0RDENT=

CALIBRESEARCH=
CEPHSEARCH=
CLOUDINITSEARCH=
KERNELSEARCH=
KUBERNETESSEARCH=
OPENSTACKSEARCH=
RABBITMQSEARCH=
HELMSEARCH=
SYSTEMDSEARCH=
DOCKERENTERPRISESEARCH=
UBUNTUSEARCH=
PROMETHEUSSEARCH=
CALICOSEARCH=
TUNGSTENSEARCH=
K0RDENTSEARCH=

GREPCASE=-i
RGCASE=-i
FINDCASE=i

CALIBREPATH=$HOME/Calibre_Library
CEPHPATH=$HOME/Downloads/tongue/docs.ceph.com/doc
CLOUDINITPATH=$HOME/Downloads/tongue/cloudinit.readthedocs.io/en/latest
KERNELPATH=$HOME/Downloads/tongue/docs.kernel.org/Documentation
KUBERNETESPATH=$HOME/Downloads/tongue/kubernetes.io/content/en/
OPENSTACKPATH=$HOME/Downloads/tongue/docs.openstack.org
RABBITMQPATH=$HOME/Downloads/tongue/www.rabbitmq.com/docs
HELMPATH=$HOME/Downloads/tongue/helm.sh/content/en/docs
SYSTEMDPATH=$HOME/Downloads/tongue/systemd.io
DOCKERENTERPRISEPATH=$HOME/Downloads/tongue/docs.docker.com/content
MIRANTISPATH=$HOME/Downloads/tongue/docs.mirantis.com
UBUNTUPATH=$HOME/Downloads/tongue/documentation.ubuntu.com/server
MARIADBPATH=$HOME/Downloads/tongue/mariadb
PROMETHEUSPATH=$HOME/Downloads/tongue/prometheus.io/content/docs
CALICOPATH=$HOME/Downloads/tongue/docs.tigera.io/calico
TUNGSTENPATH=$HOME/Downloads/tongue/github.com/OpenSDN-io/docs
K0RDENTPATH=$HOME/Downloads/tongue/github.com/k0rdent/docs/docs
LOGPATH=/var/log/tongue

while [ "$1" != "" ]; do
  case $1 in

  -a | --calibre)
    shift
    CALIBRESEARCH=yes
    FILE=pdf
    CALIBRE=$1
    shift
    ;;
  -b | --rabbitmq)
    shift
    RABBITMQSEARCH=yes
    FILE=md
    RABBITMQ=$1
    shift
    ;;
  -c | --ceph)
    shift
    CEPHSEARCH=yes
    FILE=rst
    CEPH=$1
    shift
    ;;
  -d | --docker-enterprise)
    shift
    DOCKERENTERPRISESEARCH=yes
    FILE=md
    DOCKERENTERPRISE=$1
    shift
    ;;
  -e | --openstack)
    shift
    OPENSTACKSEARCH=yes
    FILE=rst
    OPENSTACK=$1
    shift
    ;;
  -f | --prometheus)
    shift
    PROMETHEUSSEARCH=yes
    FILE=md
    PROMETHEUS=$1
    shift
    ;;
  -g | --k0rdent)
    shift
    K0RDENTSEARCH=yes
    FILE=md
    K0RDENT=$1
    shift
    ;;
  -j | --calico)
    shift
    CALICOSEARCH=yes
    FILE=mdx
    CALICO=$1
    shift
    ;;
  -k | --kubernetes)
    shift
    KUBERNETESSEARCH=yes
    FILE=md
    KUBERNETES=$1
    shift
    ;;
  -m | --mirantis)
    shift
    MIRANTISSEARCH=yes
    FILE=rst
    MIRANTIS=$1
    shift
    ;;
  -n | --kernel)
    shift
    KERNELSEARCH=yes
    FILE=rst
    KERNEL=$1
    shift
    ;;
  -o | --helm)
    shift
    HELMSEARCH=yes
    FILE=md
    HELM=$1
    shift
    ;;
  -p | --mariadb)
    shift
    MARIADBSEARCH=yes
    FILE=pdf
    MARIADB=$1
    shift
    ;;
  -q | --tungsten)
    shift
    TUNGSTENSEARCH=yes
    FILE=rst
    TUNGSTEN=$1
    shift
    ;;
  -t | --cloud-init)
    shift
    CLOUDINITSEARCH=yes
    FILE=html
    CLOUDINIT=$1
    shift
    ;;
  -u | --ubuntu)
    shift
    UBUNTUSEARCH=yes
    FILE=md
    UBUNTU=$1
    shift
    ;;
  -y | --systemd)
    shift
    SYSTEMDSEARCH=yes
    FILE=html
    SYSTEMD=$1
    shift
    ;;
  -s | --search)
    shift
    SEARCH=$1
    shift
    ;;
  -i | --case-sensitive)
    shift
    GREPCASE=
    RGCASE=
    FINDCASE=
    ;;
  -l | --list)
    shift
    LIST=yes
    ;;
  -h | --help)
    shift
    HELP=yes
    FILE=
    ;;
  *)
    shift
    HELP=yes
    ;;
  esac
done

if [ ! -d "$LOGPATH" ]; then
  echo "Seems like you are running tongue for the first time. At this stage, we need sudo permissions to create the directory $LOGPATH, where the search results will be stored. Please provide the password bellow if prompted:"
  sudo mkdir $LOGPATH
  sudo chown $USER $LOGPATH
  exit 1
fi
find $LOGPATH -type f -mtime +60 -exec rm {} \;

if ! command -v pdfgrep 2>&1 >/dev/null; then
  echo "the command pdfgrep could not be found. Installing"
  sudo dnf install pdfgrep -y
  sudo apt-get install pdfgrep -y
  exit 1
fi
if ! command -v rg 2>&1 >/dev/null; then
  echo "the command rg could not be found. Installing"
  sudo dnf install ripgrep -y
  sudo apt-get install ripgrep -y
  exit 1
fi

#if [ -z "$*" ]; then echo "No arguments found. Type 'tongue -h' to list all options"; fi

## RABBITMQ SEARCH START ##
if [ "$FILE" = "md" ] && [ "$RABBITMQSEARCH" = "yes" ]; then
  if [ -z "$RABBITMQ" ] && [ -z "$SEARCH" ]; then
    echo "RABBITMQ field (-c) and search field (-s) are empty. Possible values for (-c) field are:"
    ls --color=auto $RABBITMQPATH/ 2>/dev/null
    exit 1
  fi
  if [ -z "$RABBITMQ" ] && [ ! -z "$SEARCH" ]; then
    echo "RABBITMQ field (-c) is empty. Possible values are:"
    ls --color=auto $RABBITMQPATH 2>/dev/null
    exit 1
  fi
  if [ ! -z "$RABBITMQ" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on RABBITMQ pages for '"$RABBITMQ"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $RABBITMQPATH/$RABBITMQ 2>/dev/null | $GREP -v \:0 | sed 's/md\:/html \:/g' | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $RABBITMQPATH/$RABBITMQ 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [RABBITMQ DOCUMENTATION SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $RABBITMQPATH/$RABBITMQ 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g"*.{$FILE}" "$SEARCH" $RABBITMQPATH/$RABBITMQ | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" -e 's/\.md/\.html/g' >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [RABBITMQ DOCUMENTATION SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | less -F -X -R
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## RABBITMQ SEARCH END ##

## HELM SEARCH START ##
if [ "$FILE" = "md" ] && [ "$HELMSEARCH" = "yes" ]; then
  if [ -z "$HELM" ] && [ -z "$SEARCH" ]; then
    echo "HELM field (-o) and search field (-s) are empty. Possible values for (-o) field are:"
    ls --color=auto $HELMPATH/ 2>/dev/null
    exit 1
  fi
  if [ -z "$HELM" ] && [ ! -z "$SEARCH" ]; then
    echo "HELM field (-o) is empty. Possible values are:"
    ls --color=auto $HELMPATH 2>/dev/null
    exit 1
  fi
  if [ ! -z "$HELM" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on HELM pages for '"$HELM"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $HELMPATH/$HELM 2>/dev/null | $GREP -v \:0 | sed -e 's/md\:/html \:/g' -e 's|\/content\/en||g' | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $HELMPATH/$HELM 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [HELM DOCUMENTATION SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $HELMPATH/$HELM 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g"*.{$FILE}" "$SEARCH" $HELMPATH/$HELM | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" -e 's/\.md/\.html/g' -e 's|\/content\/en||g' >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [HELM DOCUMENTATION SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | less -F -X -R
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## HELM SEARCH END ##

## MIRANTIS SEARCH START ##
if [ "$FILE" = "rst" ] && [ "$MIRANTISSEARCH" = "yes" ]; then
  if [ -z "$MIRANTIS" ] && [ -z "$SEARCH" ]; then
    echo "MIRANTIS field (-m) and search field (-s) are empty. Possible values for (-m) field are:"
    ls --color=auto $MIRANTISPATH/ 2>/dev/null
    exit 1
  fi
  if [ -z "$MIRANTIS" ] && [ ! -z "$SEARCH" ]; then
    echo "MIRANTIS field (-m) is empty. Possible values are:"
    ls --color=auto $MIRANTISPATH 2>/dev/null
    exit 1
  fi
  if [ ! -z "$MIRANTIS" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on MIRANTIS pages for '"$MIRANTIS"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $MIRANTISPATH/$MIRANTIS 2>/dev/null | $GREP -v \:0 | sed -e 's/\.rst/\.html /g' -e 's;\/doc\/source;;g' -e 's;\/openstack-docs;;g' -e 's;\/kaas-docs;;g' -e 's;\/mke-docs;;g' -e 's;\/mcr-docs;;g' -e 's;\/mcp-docs\/doc;;g' -e 's;\/latests;;g' -e 's;\/q4-18\/doc;\/q4-18;g' -e 's;\/source;;g' | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $MIRANTISPATH/$MIRANTIS 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [MIRANTIS DOCUMENTATION SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $MIRANTISPATH/$MIRANTIS 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g"*.{$FILE}" "$SEARCH" $MIRANTISPATH/$MIRANTIS | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" -e 's/\.rst/\.html /g' -e 's;\/doc\/source;;g' -e 's;\/openstack-docs;;g' -e 's;\/kaas-docs;;g' -e 's;\/mke-docs;;g' -e 's;\/mcr-docs;;g' -e 's;\/mcp-docs\/doc;;g' -e 's;\/latests;;g' -e 's;\/q4-18\/doc;\/q4-18;g' -e 's;\/source;;g' >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [MIRANTIS DOCUMENTATION SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## MIRANTIS SEARCH END ##

## DOCKERENTERPRISE SEARCH START ##
if [ "$FILE" = "md" ] && [ "$DOCKERENTERPRISESEARCH" = "yes" ]; then
  if [ -z "$DOCKERENTERPRISE" ] && [ -z "$SEARCH" ]; then
    echo "DOCKER ENTERPRISE field (-d) and search field (-s) are empty. Possible values for (-d) field are:"
    ls --color=auto $DOCKERENTERPRISEPATH/ 2>/dev/null
    exit 1
  fi
  if [ -z "$DOCKERENTERPRISE" ] && [ ! -z "$SEARCH" ]; then
    echo "DOCKER ENTERPRISE field (-d) is empty. Possible values are:"
    ls --color=auto $DOCKERENTERPRISEPATH 2>/dev/null
    exit 1
  fi
  if [ ! -z "$DOCKERENTERPRISE" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on DOCKER ENTERPRISE pages for '"$DOCKERENTERPRISE"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $DOCKERENTERPRISEPATH/$DOCKERENTERPRISE 2>/dev/null | $GREP -v \:0 | sed -e 's/\.md/\/ /g' -e 's;content\/;;g' -e 's;_index;;g' -e 's;\/manuals;;g' -e 's;\/\/;\/;g' | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $DOCKERENTERPRISEPATH/$DOCKERENTERPRISE 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [DOCKER ENTERPRISE DOCUMENTATION SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $DOCKERENTERPRISEPATH/$DOCKERENTERPRISE 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g'*{.md}' "$SEARCH" $DOCKERENTERPRISEPATH/$DOCKERENTERPRISE | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" -e 's/\.md/\/ /g' -e 's;content\/;;g' -e 's;_index;;g' -e 's;\/manuals;;g' -e 's;\/\/;\/;g' >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [DOCKER ENTERPRISE DOCUMENTATION SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## DOCKERENTERPRISE SEARCH END ##

## CALIBRE SEARCH START ##
if [ "$FILE" = "pdf" ] && [ "$CALIBRESEARCH" = "yes" ]; then
  if [ -z "$CALIBRE" ] && [ -z "$SEARCH" ]; then
    echo "CALIBRE field (-a) and search field (-s) are empty. Possible values for (-a) field are:"
    ls -d $CALIBREPATH/*/* | sed -e "s|$CALIBREPATH||g" | $LESS2 2>/dev/null
    echo "Select only the author name for the search. Example: tongue -a 'Unknown' -s 'term'"
    exit 1
  fi
  if [ -z "$CALIBRE" ] && [ ! -z "$SEARCH" ]; then
    echo "CALIBRE field (-a) is empty. Possible values are:"
    ls -d $CALIBREPATH/*/* | sed -e "s|$CALIBREPATH||g" | $LESS2 2>/dev/null
    echo "Select only the author name for the search. Example: tongue -a 'Unknown' -s 'term'"
    exit 1
  fi
  if [ ! -z "$CALIBRE" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on local Calibre PDF library folder '"$CALIBRE"'. Please wait"
  pdfgrep -rcH $GREPCASE "$SEARCH" $CALIBREPATH/$CALIBRE 2>/dev/null | $GREP -v \:0 | sed -e 's/pdf\:/pdf \:/g' >$LOGPATH/tongue-urls-match
  pdfgrep -rcH $GREPCASE "$SEARCH" $CALIBREPATH/$CALIBRE 2>/dev/null | sed -e 's/pdf\:/pdf \:/g' >$LOGPATH/tongue-search-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [CALIBRE PDF SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  pdfgrep -rnH --color=always $GREPCASE "$SEARCH" $CALIBREPATH/$CALIBRE 2>/dev/null | sed -e "s|$CALIBREPATH|file\:\/\/$CALIBREPATH|g" -e "s| (|\%20(|g" -e "s| - |\%20-\%20|g" -e "s,\.pdf\x1B\[m\x1B\[K\x1B\[36m\x1B\[K\:,\.pdf\x1B\[m\x1B\[K\x1B\[36m\x1B\[K\#page\=,g" -e "s,\x1B\[m\x1B\[K\x1B\[36m\x1B\[K\:,\x1B\[m\x1B\[K\x1B\[36m\x1B\[K \:,g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [CALIBRE PDF PAGES SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} PDF(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed -e "s|$CALIBREPATH|file\:\/\/$CALIBREPATH|g" -e "s| (|\%20(|g" -e "s| - |\%20-\%20|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed -e "s|$CALIBREPATH|file\:\/\/$CALIBREPATH|g" -e "s| (|\%20(|g" -e "s| - |\%20-\%20|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## CALIBRE SEARCH END ##

## CEPH SEARCH START ##
if [ "$FILE" = "rst" ] && [ "$CEPHSEARCH" = "yes" ]; then
  if [ -z "$CEPH" ] && [ -z "$SEARCH" ]; then
    echo "CEPH field (-c) and search field (-s) are empty. Possible values for (-c) field are:"
    ls --color=auto $CEPHPATH/ 2>/dev/null
    exit 1
  fi
  if [ -z "$CEPH" ] && [ ! -z "$SEARCH" ]; then
    echo "CEPH field (-c) is empty. Possible values are:"
    ls --color=auto $CEPHPATH 2>/dev/null
    exit 1
  fi
  if [ ! -z "$CEPH" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on CEPH pages for '"$CEPH"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $CEPHPATH/$CEPH 2>/dev/null | $GREP -v \:0 | sed -e 's/\.rst/\/ /g' -e 's;\/doc\/;\/en\/latest\/;g' -e 's;\/index\/;;g' | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $CEPHPATH/$CEPH 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less

  printf "${RED}----------------- [CEPH DOCUMENTATION SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $CEPHPATH/$CEPH 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g"*.{rst}" "$SEARCH" $CEPHPATH/$CEPH | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" -e 's/\.rst/\/ /g' -e 's;\/doc\/;\/en\/latest\/;g' -e 's;\/index\/;;g' >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [CEPH DOCUMENTATION SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## CEPH SEARCH END ##

## CLOUD-INIT SEARCH START ##
if [ "$FILE" = "html" ] && [ "$CLOUDINITSEARCH" = "yes" ]; then
  if [ -z "$CLOUDINIT" ] && [ -z "$SEARCH" ]; then
    echo "CLOUD-INIT field (-t) and search field (-s) are empty. Possible values for (-t) field are:"
    ls -a $CLOUDINITPATH 2>/dev/null
    exit 1
  fi
  if [ -z "$CLOUDINIT" ] && [ ! -z "$SEARCH" ]; then
    echo "CLOUD-INIT field (-t) is empty. Possible values are:"
    ls --color=auto $CLOUDINITPATH 2>/dev/null
    exit 1
  fi
  if [ ! -z "$CLOUDINIT" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on CLOUDINIT for '"$CLOUDINIT"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $CLOUDINITPATH/$CLOUDINIT 2>/dev/null | $GREP -v \:0 | sed 's/html\:/html \:/g' | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $CLOUDINITPATH/$CLOUDINIT 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [CLOUD-INIT SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $CLOUDINITPATH/$CLOUDINIT 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|http\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g"*.{$FILE}" "$SEARCH" $CLOUDINITPATH/$CLOUDINIT | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [CLOUD-INIT SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/|http\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/|http\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## CLOUD-INIT SEARCH END ##

## KERNEL SEARCH START ##
if [ "$FILE" = "rst" ] && [ "$KERNELSEARCH" = "yes" ]; then
  if [ -z "$KERNEL" ] && [ -z "$SEARCH" ]; then
    echo "KERNEL field (-n) and search field (-s) are empty. Possible values for (-n) field are:"
    ls --color=auto $KERNELPATH 2>/dev/null
    exit 1
  fi
  if [ -z "$KERNEL" ] && [ ! -z "$SEARCH" ]; then
    echo "KERNEL field (-n) is empty. Possible values are:"
    ls --color=auto $KERNELPATH 2>/dev/null
    exit 1
  fi
  if [ ! -z "$KERNEL" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on KERNEL pages for '"$KERNEL"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $KERNELPATH/$KERNEL 2>/dev/null | $GREP -v \:0 | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" -e 's/\.rst/\.html /g' -e "s;\/Documentation;;g" | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $KERNELPATH/$KERNEL 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [KERNEL PAGES SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $KERNELPATH/$KERNEL 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g"*.{$FILE}" "$SEARCH" $KERNELPATH/$KERNEL | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" -e 's/\.rst/\.html /g' -e "s;\/Documentation;;g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [KERNEL PAGES SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## KERNEL SEARCH END ##

## KUBERNETES SEARCH START ##
if [ "$FILE" = "md" ] && [ "$KUBERNETESSEARCH" = "yes" ]; then
  if [ -z "$KUBERNETES" ] && [ -z "$SEARCH" ]; then
    echo "KUBERNETES field (-k) and search field (-s) are empty. Possible values for (-k) field are:"
    ls --color=auto $KUBERNETESPATH/ 2>/dev/null
    exit 1
  fi
  if [ -z "$KUBERNETES" ] && [ ! -z "$SEARCH" ]; then
    echo "KUBERNETES field (-k) is empty. Possible values are:"
    ls --color=auto $KUBERNETESPATH 2>/dev/null
    exit 1
  fi
  if [ ! -z "$KUBERNETES" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on KUBERNETES pages for '"$KUBERNETES"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $KUBERNETESPATH/$KUBERNETES 2>/dev/null | $GREP -v \:0 | sed -e 's/md\:/html \:/g' -e 's;\/content\/en\/;;g' -e 's;_index\.html;index\.html;g' | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $KUBERNETESPATH/$KUBERNETES 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [KUBERNETES DOCUMENTATION SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $KUBERNETESPATH/$KUBERNETES 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g'*{.md}' "$SEARCH" $KUBERNETESPATH/$KUBERNETES | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" -e 's/\.md/\.html/g' -e 's;\/content\/en\/;;g' -e 's;_index\.html;index\.html;g' >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [KUBERNETES DOCUMENTATION SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## KUBERNETES SEARCH END ##

## MARIADB SEARCH START ##
if [ "$FILE" = "pdf" ] && [ "$MARIADBSEARCH" = "yes" ]; then
  if [ -z "$MARIADB" ] && [ -z "$SEARCH" ]; then
    echo "MARIADB field (-p) and search field (-s) are empty. Possible values for (-p) field are:"
    ls -d $MARIADBPATH/* | sed -e "s|$MARIADBPATH||g" | $LESS2 2>/dev/null
    exit 1
  fi
  if [ -z "$MARIADB" ] && [ ! -z "$SEARCH" ]; then
    echo "MARIADB field (-p) is empty. Possible values are:"
    ls -d $MARIADBPATH/* | sed -e "s|$MARIADBPATH||g" | $LESS2 2>/dev/null
    exit 1
  fi
  if [ ! -z "$MARIADB" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on local Mariadb folder '"$MARIADB"'. Please wait"
  pdfgrep -rcH $GREPCASE "$SEARCH" $MARIADBPATH/$MARIADB 2>/dev/null | $GREP -v \:0 | sed -e 's/pdf\:/pdf \:/g' >$LOGPATH/tongue-urls-match
  pdfgrep -rcH $GREPCASE "$SEARCH" $MARIADBPATH/$MARIADB 2>/dev/null | sed -e 's/pdf\:/pdf \:/g' >$LOGPATH/tongue-search-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [MARIADB PDF SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  pdfgrep -rnH --color=always $GREPCASE "$SEARCH" $MARIADBPATH/$MARIADB 2>/dev/null | sed -e "s|$MARIADBPATH|file\:\/\/$MARIADBPATH|g" -e "s| (|\%20(|g" -e "s| - |\%20-\%20|g" -e "s,\.pdf\x1B\[m\x1B\[K\x1B\[36m\x1B\[K\:,\.pdf\x1B\[m\x1B\[K\x1B\[36m\x1B\[K\#page\=,g" -e "s,\x1B\[m\x1B\[K\x1B\[36m\x1B\[K\:,\x1B\[m\x1B\[K\x1B\[36m\x1B\[K \:,g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [MARIADB PDF PAGES SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} PDF(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed -e "s|$MARIADBPATH|file\:\/\/$MARIADBPATH|g" -e "s| (|\%20(|g" -e "s| - |\%20-\%20|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed -e "s|$MARIADBPATH|file\:\/\/$MARIADBPATH|g" -e "s| (|\%20(|g" -e "s| - |\%20-\%20|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## MARIADB SEARCH END ##

## OPENSTACK SEARCH START ##
if [ "$FILE" = "rst" ] && [ "$OPENSTACKSEARCH" = "yes" ]; then
  if [ -z "$OPENSTACK" ] && [ -z "$SEARCH" ]; then
    echo "OPENSTACK field (-e) and search field (-s) are empty. Possible values for (-e) field are:"
    ls --color=auto $OPENSTACKPATH/ 2>/dev/null
    exit 1
  fi
  if [ -z "$OPENSTACK" ] && [ ! -z "$SEARCH" ]; then
    echo "OPENSTACK field (-e) is empty. Possible values are:"
    ls --color=auto $OPENSTACKPATH 2>/dev/null
    exit 1
  fi
  if [ ! -z "$OPENSTACK" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on OPENSTACK pages for '"$OPENSTACK"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $OPENSTACKPATH/$OPENSTACK 2>/dev/null | $GREP -v \:0 | sed -e 's/\.rst/\.html /g' -e 's;\/doc\/source\/;\/latest\/;g' -e 's;README\.html;;g' | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $OPENSTACKPATH/$OPENSTACK 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [OPENSTACK DOCUMENTATION SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $OPENSTACKPATH/$OPENSTACK 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g"*.{rst}" "$SEARCH" $OPENSTACKPATH/$OPENSTACK | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" -e 's/\.rst/\.html /g' -e 's;\/doc\/source\/;\/latest\/;g' -e 's;README\.html;;g' >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [OPENSTACK DOCUMENTATION SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## OPENSTACK SEARCH END ##

## SYSTEMD SEARCH START ##
if [ "$FILE" = "html" ] && [ "$SYSTEMDSEARCH" = "yes" ]; then
  if [ -z "$SYSTEMD" ] && [ -z "$SEARCH" ]; then
    echo "SYSTEMD field (-y) and search field (-s) are empty. Possible values for (-y) field are:"
    ls --color=auto $SYSTEMDPATH 2>/dev/null
    exit 1
  fi
  if [ -z "$SYSTEMD" ] && [ ! -z "$SEARCH" ]; then
    echo "SYSTEMD field (-y) is empty. Possible values are:"
    ls --color=auto $SYSTEMDPATH 2>/dev/null
    exit 1
  fi
  if [ ! -z "$SYSTEMD" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on SYSTEMD pages for '"$SYSTEMD"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $SYSTEMDPATH/$SYSTEMD 2>/dev/null | $GREP -v \:0 | sed 's/html\:/html \:/g' | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $SYSTEMDPATH/$SYSTEMD 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [SYSTEMD SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $SYSTEMDPATH/$SYSTEMD 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g"*.{$FILE}" "$SEARCH" $SYSTEMDPATH/$SYSTEMD | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [SYSTEMD SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## SYSTEMD SEARCH END ##

## UBUNTU SEARCH START ##
if [ "$FILE" = "md" ] && [ "$UBUNTUSEARCH" = "yes" ]; then
  if [ -z "$UBUNTU" ] && [ -z "$SEARCH" ]; then
    echo "UBUNTU field (-u) and search field (-s) are empty. Possible values for (-u) field are:"
    ls --color=auto $UBUNTUPATH/ 2>/dev/null
    exit 1
  fi
  if [ -z "$UBUNTU" ] && [ ! -z "$SEARCH" ]; then
    echo "UBUNTU field (-u) is empty. Possible values are:"
    ls --color=auto $UBUNTUPATH/ 2>/dev/null
    exit 1
  fi
  if [ ! -z "$UBUNTU" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on UBUNTU pages for '"$UBUNTU"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $UBUNTUPATH/$UBUNTU 2>/dev/null | $GREP -v \:0 | sed 's/\.md/\/ /g' | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $UBUNTUPATH/$UBUNTU 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [UBUNTU DOCUMENTATION SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $UBUNTUPATH/$UBUNTU 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g"*.{$FILE}" "$SEARCH" $UBUNTUPATH/$UBUNTU | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" -e 's/\.md/\/ /g' >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [UBUNTU DOCUMENTATION SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## UBUNTU SEARCH END ##

## PROMETHEUS SEARCH START ##
if [ "$FILE" = "md" ] && [ "$PROMETHEUSSEARCH" = "yes" ]; then
  if [ -z "$PROMETHEUS" ] && [ -z "$SEARCH" ]; then
    echo "PROMETHEUS field (-f) and search field (-s) are empty. Possible values for (-f) field are:"
    ls --color=auto $PROMETHEUSPATH/ 2>/dev/null
    exit 1
  fi
  if [ -z "$PROMETHEUS" ] && [ ! -z "$SEARCH" ]; then
    echo "PROMETHEUS field (-f) is empty. Possible values are:"
    ls --color=auto $PROMETHEUSPATH/ 2>/dev/null
    exit 1
  fi
  if [ ! -z "$PROMETHEUS" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on PROMETHEUS pages for '"$PROMETHEUS"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $PROMETHEUSPATH/$PROMETHEUS 2>/dev/null | $GREP -v \:0 | sed -e 's/\.md/\/ /g' -e 's;\/content;;g' | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $PROMETHEUSPATH/$PROMETHEUS 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [PROMETHEUS DOCUMENTATION SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $PROMETHEUSPATH/$PROMETHEUS 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g"*.{$FILE}" "$SEARCH" $PROMETHEUSPATH/$PROMETHEUS | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" -e 's/\.md/\/ /g' -e 's;\/content;;g' >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [PROMETHEUS DOCUMENTATION SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## PROMETHEUS SEARCH END ##

## CALICO SEARCH START ##
if [ "$FILE" = "mdx" ] && [ "$CALICOSEARCH" = "yes" ]; then
  if [ -z "$CALICO" ] && [ -z "$SEARCH" ]; then
    echo "CALICO field (-j) and search field (-s) are empty. Possible values for (-j) field are:"
    ls --color=auto $CALICOPATH/ 2>/dev/null
    exit 1
  fi
  if [ -z "$CALICO" ] && [ ! -z "$SEARCH" ]; then
    echo "CALICO field (-j) is empty. Possible values are:"
    ls --color=auto $CALICOPATH/ 2>/dev/null
    exit 1
  fi
  if [ ! -z "$CALICO" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on CALICO pages for '"$CALICO"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $CALICOPATH/$CALICO 2>/dev/null | $GREP -v \:0 | sed -e 's/\.mdx/\/ /g' -e 's;\/calico;\/calico\/latest;g' -e 's;\/index\/;;g' | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $CALICOPATH/$CALICO 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [CALICO DOCUMENTATION SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $CALICOPATH/$CALICO 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g"*.{mdx}" "$SEARCH" $CALICOPATH/$CALICO | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" -e 's/\.mdx/\/ /g' -e 's;\/calico;\/calico\/latest;g' -e 's;\/index\/;;g' >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [CALICO DOCUMENTATION SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## CALICO SEARCH END ##

## TUNGSTEN SEARCH START ##
if [ "$FILE" = "rst" ] && [ "$TUNGSTENSEARCH" = "yes" ]; then
  if [ -z "$TUNGSTEN" ] && [ -z "$SEARCH" ]; then
    echo "TUNGSTEN field (-q) and search field (-s) are empty. Possible values for (-q) field are:"
    ls --color=auto $TUNGSTENPATH/ 2>/dev/null
    exit 1
  fi
  if [ -z "$TUNGSTEN" ] && [ ! -z "$SEARCH" ]; then
    echo "TUNGSTEN field (-q) is empty. Possible values are:"
    ls --color=auto $TUNGSTENPATH/ 2>/dev/null
    exit 1
  fi
  if [ ! -z "$TUNGSTEN" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on TUNGSTEN pages for '"$TUNGSTEN"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $TUNGSTENPATH/$TUNGSTEN 2>/dev/null | $GREP -v \:0 | sed -e 's;\.rst;\.rst ;g' -e 's;\/docs;\/docs\/tree\/master;g' | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $TUNGSTENPATH/$TUNGSTEN 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [TUNGSTEN DOCUMENTATION SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $TUNGSTENPATH/$TUNGSTEN 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g"*.{$FILE}" "$SEARCH" $TUNGSTENPATH/$TUNGSTEN | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" -e 's;\.rst;\.rst ;g' -e 's;\/docs;\/docs\/tree\/master;g' >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [TUNGSTEN DOCUMENTATION SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## TUNGSTEN SEARCH END ##

## K0RDENT SEARCH START ##
if [ "$FILE" = "md" ] && [ "$K0RDENTSEARCH" = "yes" ]; then
  if [ -z "$K0RDENT" ] && [ -z "$SEARCH" ]; then
    echo "K0RDENT field (-g) and search field (-s) are empty. Possible values for (-g) field are:"
    ls --color=auto $K0RDENTPATH/ 2>/dev/null
    exit 1
  fi
  if [ -z "$K0RDENT" ] && [ ! -z "$SEARCH" ]; then
    echo "K0RDENT field (-g) is empty. Possible values are:"
    ls --color=auto $K0RDENTPATH 2>/dev/null
    exit 1
  fi
  if [ ! -z "$K0RDENT" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi
  # save url list
  echo "Searching for '"$SEARCH"' on K0RDENT pages for '"$K0RDENT"'. Please wait"
  $GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $K0RDENTPATH/$K0RDENT 2>/dev/null | $GREP -v \:0 | sed -e 's/\.md/\/ /g' | sort -V >$LOGPATH/tongue-urls-match
  #$GREP -E -rc $GREPCASE --include \*.$FILE "$SEARCH" $K0RDENTPATH/$K0RDENT 2>/dev/null | $GREP -v \:0 | sort -V >$LOGPATH/tongue-urls-match
  $GREP -E -rl $GREPCASE --include \*.$FILE "$SEARCH" $K0RDENTPATH/$K0RDENT 2>/dev/null >$LOGPATH/tongue-urls
  URLNUMBER=$(cat $LOGPATH/tongue-urls-match | wc -l)
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi
  # perform search and pipe it to less
  printf "${RED}----------------- [K0RDENT DOCUMENTATION SEARCH RESULTS] -----------------${NC}\n" >$LOGPATH/tongue-results-$DATE
  #$GREP -E --color=always -r $GREPCASE --include \*.$FILE "$SEARCH" $K0RDENTPATH/$K0RDENT 2>/dev/null | sed -e "s|$HOME\/Downloads\/tongue\/|https\:\/\/|g" >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $RG $RGCASE -g'*{.md}' "$SEARCH" $K0RDENTPATH/$K0RDENT | sed -e "s|$HOME\/Downloads\/tongue\/github\.com\/k0rdent\/docs\/docs|https\:\/\/docs\.k0rdent-enterprise\.io\/latest|g" -e 's/\.md/\/ /g' >>$(ls -t $LOGPATH/tongue-results* | head -1)
  $LESS1 $(ls -t $LOGPATH/tongue-results* | head -1)
  # show report
  echo " "
  printf "${RED}----------------- [K0RDENT DOCUMENTATION SEARCH REPORT] -----------------${NC}\n" >$LOGPATH/tongue-reports
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >>$LOGPATH/tongue-reports
  cat $LOGPATH/tongue-urls-match >>$LOGPATH/tongue-reports
  sed "s|$HOME\/Downloads\/tongue\/github\.com\/k0rdent\/docs\/docs|https\:\/\/docs\.k0rdent-enterprise\.io\/latest|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n >>$(ls -t $LOGPATH/tongue-results* | head -1)
  sed "s|$HOME\/Downloads\/tongue\/github\.com\/k0rdent\/docs\/docs|https\:\/\/docs\.k0rdent-enterprise\.io\/latest|g" $LOGPATH/tongue-reports | sort -n -t ':' -k3n,3n | $LESS2
  echo " "
  echo "The search results were saved to $(ls -t $LOGPATH/tongue-results* | head -1)"
  echo " "
fi
## K0RDENT SEARCH END ##

## HELP START ##
if [ "$HELP" = "yes" ] && [ "$FILE" = "" ]; then
  echo "Examples:"
  echo "List documentations or ask for help: tongue -h or -l"
  echo "Ubuntu Documentation search: tongue -u DOCUMENTATION -s SEARCH_STRING (options: -i for case-sensitive search)"
  echo "Kubernetes documentation: tongue -k RELEASENOTE -s SEARCH_STRING (options: -i for case-sensitive search)"
  echo " "
  echo "Option list:"
  echo "-a, --calibre = Search on Calibre library"
  echo "-b, --rabbitmq = Search on rabbitmq official documentation"
  echo "-c, --ceph = Search on Ceph official documentation"
  echo "-d, --docker-enterprise = Search on docker enterprise documentation"
  echo "-e, --openstack = Search on openstack official documentation"
  echo "-f, --prometheus = Search on prometheus documentation"
  echo "-g, --k0rdent = Search on k0rdent documentation"
  echo "-h, --help = Display a list of options to chose from"
  echo "-i, --case-sensitive = Searches are case sensitive."
  echo "-j, --calico = Search on Calico documentation"
  echo "-k, --kubernetes = Search on kubernetes official documentation"
  echo "-l, --list = Display a list of documentations that you can select"
  echo "-m, --mirantis = Search on mirantis documentation"
  echo "-n, --kernel = Search on kernel official documentation"
  echo "-o, --helm = Search on helm official documentation"
  echo "-p, --mariadb = Search on mariadb documentation"
  echo "-q, --tungsten = Search on Tungsten Fabric documentation"
  echo "-s, --search = Search string. If you are searching for more then one word, put all into quotes ''"
  echo "-t, --cloud-init = Search on cloud-init documentation"
  echo "-u, --ubuntu = Search on ubuntu official documentation"
  echo "-y, --systemd = Search on systemd official documentation"
  echo " "
  echo "Practical examples:"
  echo "Search for multiple e-books/authors: tongue -a '*Sebastian*' -s 'system wide trusted certificate'"
  echo "Search only on ubuntu 16.x documentation pages: tongue -u '*16*' -s 'system wide trusted certificate'"
  echo "Search for nova on all openstack documentation: tongue -e '*' -s 'nova'"
  echo "Search for 'ocfs2' or 'nfs' on systemd documentation: tongue -y '*' -s ocfs2|nfs"
fi
## HELP END ##

## LIST START ##
if [ "$LIST" = "yes" ]; then
  printf "${RED}Here is a list of calibre library files that you can select with the option "-a" (calibre search):${NC}\n"
  echo " "
  ls -d $CALIBREPATH/*/* | sed -e "s|$HOME\/Calibre\/||g" 2>/dev/null
  echo " "
  printf "${RED}Here is a list on RABBITMQ that you can select with the option "-b" (rabbitmq search):${NC}\n"
  echo " "
  ls --color=auto $CEPHPATH 2>/dev/null
  echo " "
  printf "${RED}Here is a list on CEPH that you can search with the option "-c" (ceph search):${NC}\n"
  echo " "
  ls --color=auto $CEPHPATH 2>/dev/null
  echo " "
  printf "${RED}Here is a list on DOCKER-ENTERPRISE that you can search with the option "-d" (docker-enterprise search):${NC}\n"
  echo " "
  ls --color=auto $DOCKERENTERPRISEPATH 2>/dev/null
  echo " "
  printf "${RED}Here is a list on OPENSTACK that you can search with the option "-e" (openstack search):${NC}\n"
  echo " "
  ls --color=auto $OPENSTACKPATH 2>/dev/null
  echo " "
  printf "${RED}Here is a list on PROMETHEUS that you can search with the option "-f" (prometheus search):${NC}\n"
  echo " "
  ls --color=auto $PROMETHEUSPATH 2>/dev/null
  echo " "
  printf "${RED}Here is a list on CALICO that you can search with the option "-j" (calico search):${NC}\n"
  echo " "
  ls --color=auto $CALICOPATH 2>/dev/null
  echo " "
  printf "${RED}Here is a list on KUBERNETES that you can search with the option "-k" (kubernetes search):${NC}\n"
  echo " "
  ls --color=auto $KUBERNETESPATH 2>/dev/null
  echo " "
  printf "${RED}Here is a list on MIRANTIS that you can search with the option "-m" (mirantis search):${NC}\n"
  echo " "
  ls --color=auto $MIRANTISPATH 2>/dev/null
  echo " "
  printf "${RED}Here is a list on KERNEL that you can search with the option "-n" (kernel search):${NC}\n"
  echo " "
  ls --color=auto $KERNELPATH 2>/dev/null
  echo " "
  printf "${RED}Here is a list on HELM that you can search with the option "-o" (helm search):${NC}\n"
  echo " "
  ls --color=auto $HELMPATH 2>/dev/null
  echo " "
  printf "${RED}Here is a list on MARIADB that you can search with the option "-p" (mariadb search):${NC}\n"
  echo " "
  ls --color=auto $MARIADBPATH 2>/dev/null
  echo " "
  printf "${RED}Here is a list on TUNGSTEN that you can search with the option "-q" (tunsten search):${NC}\n"
  echo " "
  ls --color=auto $TUNGSTENPATH 2>/dev/null
  echo " "
  printf "${RED}Here is a list on CLOUDINIT that you can search with the option "-t" (cloud-init search):${NC}\n"
  echo " "
  ls --color=auto $CLOUDINITPATH/*/ | sed -e "s|$HOME\/Downloads\/tongue\/cloudinit.readthedocs.io\/en\/latest\/topics||g" 2>/dev/null
  echo " "
  printf "${RED}Here is a list on UBUNTU documentation that you can search with the option "-u" (ubuntu search):${NC}\n"
  echo " "
  ls --color=auto $UBUNTUPATH 2>/dev/null
  echo " "
  printf "${RED}Here is a list on SYSTEMD that you can search with the option "-y" (systemd search):${NC}\n"
  echo " "
  ls --color=auto $SYSTEMDPATH 2>/dev/null
  echo " "
  printf "${RED}NOTE: You can also use "*" character as a wildcard (example: "sles*")${NC}\n"

fi
## LIST END ##
