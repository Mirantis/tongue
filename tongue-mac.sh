#!/bin/bash

# --- Color Definitions ---
RED='\033[0;31m'
NC='\033[0m'

DATE=$(date +"%d-%m-%Y-%H-%M-%S")
export LESSCHARSET="utf-8"

LESS1="less -x4RFWs"
LESS2="less -F -X -R"
GREP="ggrep --color=auto"
RG="rg --encoding=UTF-8 --pretty"

LOGPATH="/var/log/tongue"
BASE_DOCS="$HOME/Downloads/tongue"

# --- Reset Variables ---
CALIBRE="" CEPH="" CLOUDINIT="" KERNEL="" KUBERNETES="" OPENSTACK="" RABBITMQ="" HELM="" SYSTEMD="" DOCKERENTERPRISE="" UBUNTU="" PROMETHEUS="" CALICO="" TUNGSTEN="" K0RDENT="" MARIADB="" MIRANTIS=""
CALIBRESEARCH="" CEPHSEARCH="" CLOUDINITSEARCH="" KERNELSEARCH="" KUBERNETESSEARCH="" OPENSTACKSEARCH="" RABBITMQSEARCH="" HELMSEARCH="" SYSTEMDSEARCH="" DOCKERENTERPRISESEARCH="" UBUNTUSEARCH="" PROMETHEUSSEARCH="" CALICOSEARCH="" TUNGSTENSEARCH="" K0RDENTSEARCH="" MARIADBSEARCH="" MIRANTISSEARCH=""

GREPCASE="-i"
RGCASE="-i"
FILE="html"
SEARCH=""
LIST=""
HELP=""

# --- Argument Parsing ---
while [ "$1" != "" ]; do
  case $1 in
  -a | --calibre)           shift; CALIBRESEARCH=yes; FILE=pdf; CALIBRE="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -b | --rabbitmq)          shift; RABBITMQSEARCH=yes; FILE=md; RABBITMQ="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -c | --ceph)              shift; CEPHSEARCH=yes; FILE=rst; CEPH="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -d | --docker-enterprise) shift; DOCKERENTERPRISESEARCH=yes; FILE=md; DOCKERENTERPRISE="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -e | --openstack)         shift; OPENSTACKSEARCH=yes; FILE=rst; OPENSTACK="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -f | --prometheus)        shift; PROMETHEUSSEARCH=yes; FILE=md; PROMETHEUS="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -g | --k0rdent)           shift; K0RDENTSEARCH=yes; FILE=md; K0RDENT="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -j | --calico)            shift; CALICOSEARCH=yes; FILE=mdx; CALICO="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -k | --kubernetes)        shift; KUBERNETESSEARCH=yes; FILE=md; KUBERNETES="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -m | --mirantis)          shift; MIRANTISSEARCH=yes; FILE=rst; MIRANTIS="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -n | --kernel)            shift; KERNELSEARCH=yes; FILE=rst; KERNEL="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -o | --helm)              shift; HELMSEARCH=yes; FILE=md; HELM="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -p | --mariadb)           shift; MARIADBSEARCH=yes; FILE=pdf; MARIADB="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -q | --tungsten)          shift; TUNGSTENSEARCH=yes; FILE=rst; TUNGSTEN="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -t | --cloud-init)        shift; CLOUDINITSEARCH=yes; FILE=html; CLOUDINIT="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -u | --ubuntu)            shift; UBUNTUSEARCH=yes; FILE=md; UBUNTU="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -y | --systemd)           shift; SYSTEMDSEARCH=yes; FILE=html; SYSTEMD="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -s | --search)            shift; SEARCH="${1:-}"; [ -n "${1:-}" ] && shift ;;
  -i | --case-sensitive)    shift; GREPCASE=""; RGCASE="" ;;
  -l | --list)              shift; LIST=yes ;;
  -h | --help)              shift; HELP=yes; FILE="" ;;
  *)                        shift; HELP=yes ;;
  esac
done

# --- Initialization & Dependency Checks ---
if [ ! -d "$LOGPATH" ]; then
  echo "Seems like you are running tongue for the first time. At this stage, we need sudo permissions to create the directory $LOGPATH, where the search results will be stored. Please provide the password below if prompted:"
  sudo mkdir -p "$LOGPATH"
  sudo chown "$USER" "$LOGPATH"
  exit 1
fi
find "$LOGPATH" -type f -mtime +60 -exec rm {} + 2>/dev/null

if ! command -v ggrep >/dev/null 2>&1; then
  echo "the command ggrep could not be found. Installing"
  brew install ggrep
  exit 1
fi
if ! command -v pdfgrep >/dev/null 2>&1; then
  echo "the command pdfgrep could not be found. Installing"
  brew install pdfgrep
  exit 1
fi
if ! command -v rg >/dev/null 2>&1; then
  echo "the command rg could not be found. Installing"
  brew install ripgrep
  exit 1
fi

CALIBREPATH="$HOME/calibre"
CEPHPATH="$BASE_DOCS/docs.ceph.com/doc"
CLOUDINITPATH="$BASE_DOCS/cloudinit.readthedocs.io/en/latest"
KERNELPATH="$BASE_DOCS/docs.kernel.org/Documentation"
KUBERNETESPATH="$BASE_DOCS/kubernetes.io/content/en"
OPENSTACKPATH="$BASE_DOCS/docs.openstack.org"
RABBITMQPATH="$BASE_DOCS/www.rabbitmq.com/docs"
HELMPATH="$BASE_DOCS/helm.sh/content/en/docs"
SYSTEMDPATH="$BASE_DOCS/systemd.io"
DOCKERENTERPRISEPATH="$BASE_DOCS/docs.docker.com/content"
MIRANTISPATH="$BASE_DOCS/docs.mirantis.com"
UBUNTUPATH="$BASE_DOCS/documentation.ubuntu.com/server"
MARIADBPATH="$BASE_DOCS/mariadb"
PROMETHEUSPATH="$BASE_DOCS/prometheus.io/content/docs"
CALICOPATH="$BASE_DOCS/docs.tigera.io/calico"
TUNGSTENPATH="$BASE_DOCS/github.com/OpenSDN-io/docs"
K0RDENTPATH="$BASE_DOCS/github.com/k0rdent/docs"

# --- Generic Search Engine Function ---
run_search() {
  local target_name="$1"
  local target_val="$2"
  local target_path="$3"
  local flag_opt="$4"
  local transform_sed="$5"

  if [ -z "$target_val" ] && [ -z "$SEARCH" ]; then
    echo "$target_name field ($flag_opt) and search field (-s) are empty. Possible values for ($flag_opt) field are:"
    ls --color=auto "$target_path/" 2>/dev/null
    exit 1
  fi
  if [ -z "$target_val" ] && [ -n "$SEARCH" ]; then
    echo "$target_name field ($flag_opt) is empty. Possible values are:"
    ls --color=auto "$target_path" 2>/dev/null
    exit 1
  fi
  if [ -n "$target_val" ] && [ -z "$SEARCH" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi

  echo "Searching for '$SEARCH' on $target_name pages for '$target_val'. Please wait"

  # Expand target path with glob support
  eval "SEARCH_TARGETS=($target_path/$target_val)"

  if [ "$FILE" = "pdf" ]; then
    pdfgrep -rcH $GREPCASE "$SEARCH" "${SEARCH_TARGETS[@]}" 2>/dev/null | $GREP -v ':0' | sed -e 's/pdf:/pdf :/g' > "$LOGPATH/tongue-urls-match"
  else
    rg $RGCASE -g "*.$FILE" -l "$SEARCH" "${SEARCH_TARGETS[@]}" 2>/dev/null > "$LOGPATH/tongue-urls"
    rg $RGCASE -g "*.$FILE" -c "$SEARCH" "${SEARCH_TARGETS[@]}" 2>/dev/null | $GREP -v ':0' | sed -e "$transform_sed" | sort -V > "$LOGPATH/tongue-urls-match"
  fi

  URLNUMBER=$(wc -l < "$LOGPATH/tongue-urls-match" | tr -d ' ')
  if [ "$URLNUMBER" = "0" ]; then
    echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
    exit 1
  fi

  printf "${RED}----------------- [%s DOCUMENTATION SEARCH RESULTS] -----------------${NC}\n" "$target_name" > "$LOGPATH/tongue-results-$DATE"

  if [ "$FILE" = "pdf" ]; then
    pdfgrep -rnH --color=always $GREPCASE "$SEARCH" "${SEARCH_TARGETS[@]}" 2>/dev/null | \
      sed -e "s|$target_path|file://$target_path|g" -e "s| (|\%20(|g" -e "s| - |\%20-\%20|g" -e "s,\.pdf\x1B\[m\x1B\[K\x1B\[36m\x1B\[K\:,\.pdf\x1B\[m\x1B\[K\x1B\[36m\x1B\[K\#page\=,g" -e "s,\x1B\[m\x1B\[K\x1B\[36m\x1B\[K\:,\x1B\[m\x1B\[K\x1B\[36m\x1B\[K \:,g" >> "$LOGPATH/tongue-results-$DATE"
  else
    $RG $RGCASE -g "*.$FILE" "$SEARCH" "${SEARCH_TARGETS[@]}" | sed -e "$transform_sed" >> "$LOGPATH/tongue-results-$DATE"
  fi

  $LESS1 "$LOGPATH/tongue-results-$DATE"

  echo " "
  printf "${RED}----------------- [%s DOCUMENTATION SEARCH REPORT] -----------------${NC}\n" "$target_name" > "$LOGPATH/tongue-reports"
  printf "The term '${RED}$SEARCH${NC}' was found on ${RED}$URLNUMBER${NC} page(s):\n" >> "$LOGPATH/tongue-reports"
  cat "$LOGPATH/tongue-urls-match" >> "$LOGPATH/tongue-reports"

  sed "s|$HOME/Downloads/tongue/|https://|g" "$LOGPATH/tongue-reports" | sort -n -t ':' -k3n,3n >> "$LOGPATH/tongue-results-$DATE"
  sed "s|$HOME/Downloads/tongue/|https://|g" "$LOGPATH/tongue-reports" | sort -n -t ':' -k3n,3n | $LESS2

  echo " "
  echo "The search results were saved to $LOGPATH/tongue-results-$DATE"
  echo " "
}

# --- Execution Routes ---
if [ "$FILE" = "md" ] && [ "$RABBITMQSEARCH" = "yes" ]; then
  run_search "RABBITMQ" "$RABBITMQ" "$RABBITMQPATH" "-b" "s/md:/html :/g"
fi

if [ "$FILE" = "md" ] && [ "$HELMSEARCH" = "yes" ]; then
  run_search "HELM" "$HELM" "$HELMPATH" "-o" "s/md:/html :/g; s|/content/en||g"
fi

if [ "$FILE" = "rst" ] && [ "$MIRANTISSEARCH" = "yes" ]; then
  run_search "MIRANTIS" "$MIRANTIS" "$MIRANTISPATH" "-m" "s/\.rst/\.html /g; s;/doc/source;;g; s;/openstack-docs;;g; s;/kaas-docs;;g; s;/mke-docs;;g; s;/mcr-docs;;g; s;/mcp-docs/doc;;g; s;/latests;;g; s;/q4-18/doc;/q4-18;g; s;/source;;g"
fi

if [ "$FILE" = "md" ] && [ "$DOCKERENTERPRISESEARCH" = "yes" ]; then
  run_search "DOCKER ENTERPRISE" "$DOCKERENTERPRISE" "$DOCKERENTERPRISEPATH" "-d" "s/\.md/\/ /g; s;content/;;g; s;_index;;g; s;/manuals;;g; s;//;/;g"
fi

if [ "$FILE" = "pdf" ] && [ "$CALIBRESEARCH" = "yes" ]; then
  run_search "CALIBRE" "$CALIBRE" "$CALIBREPATH" "-a" ""
fi

if [ "$FILE" = "rst" ] && [ "$CEPHSEARCH" = "yes" ]; then
  run_search "CEPH" "$CEPH" "$CEPHPATH" "-c" "s/\.rst/\/ /g; s;/doc/;/en/latest/;g; s;/index/;;g"
fi

if [ "$FILE" = "html" ] && [ "$CLOUDINITSEARCH" = "yes" ]; then
  run_search "CLOUD-INIT" "$CLOUDINIT" "$CLOUDINITPATH" "-t" "s/html:/html :/g"
fi

if [ "$FILE" = "rst" ] && [ "$KERNELSEARCH" = "yes" ]; then
  run_search "KERNEL" "$KERNEL" "$KERNELPATH" "-n" "s|$HOME/Downloads/tongue/|https://|g; s/\.rst/\.html /g; s;/Documentation;;g"
fi

if [ "$FILE" = "md" ] && [ "$KUBERNETESSEARCH" = "yes" ]; then
  run_search "KUBERNETES" "$KUBERNETES" "$KUBERNETESPATH" "-k" "s/md:/html :/g; s;/content/en/;;g; s;_index\.html;index\.html;g"
fi

if [ "$FILE" = "pdf" ] && [ "$MARIADBSEARCH" = "yes" ]; then
  run_search "MARIADB" "$MARIADB" "$MARIADBPATH" "-p" ""
fi

if [ "$FILE" = "rst" ] && [ "$OPENSTACKSEARCH" = "yes" ]; then
  run_search "OPENSTACK" "$OPENSTACK" "$OPENSTACKPATH" "-e" "s/\.rst/\.html /g; s;/doc/source/;/latest/;g; s;README\.html;;g"
fi

if [ "$FILE" = "html" ] && [ "$SYSTEMDSEARCH" = "yes" ]; then
  run_search "SYSTEMD" "$SYSTEMD" "$SYSTEMDPATH" "-y" "s/html:/html :/g"
fi

if [ "$FILE" = "md" ] && [ "$UBUNTUSEARCH" = "yes" ]; then
  run_search "UBUNTU" "$UBUNTU" "$UBUNTUPATH" "-u" "s/\.md/\/ /g"
fi

if [ "$FILE" = "md" ] && [ "$PROMETHEUSSEARCH" = "yes" ]; then
  run_search "PROMETHEUS" "$PROMETHEUS" "$PROMETHEUSPATH" "-f" "s/\.md/\/ /g; s;/content;;g"
fi

if [ "$FILE" = "mdx" ] && [ "$CALICOSEARCH" = "yes" ]; then
  run_search "CALICO" "$CALICO" "$CALICOPATH" "-j" "s/\.mdx/\/ /g; s;/calico;/calico/latest;g; s;/index/;;g"
fi

if [ "$FILE" = "rst" ] && [ "$TUNGSTENSEARCH" = "yes" ]; then
  run_search "TUNGSTEN" "$TUNGSTEN" "$TUNGSTENPATH" "-q" "s;\.rst;\.rst ;g; s;/docs;/docs/tree/master;g"
fi

if [ "$FILE" = "md" ] && [ "$K0RDENTSEARCH" = "yes" ]; then
  run_search "K0RDENT" "$K0RDENT" "$K0RDENTPATH" "-g" "s/\.md/\/ /g"
fi

# --- Help Block ---
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
fi

# --- List Block ---
if [ "$LIST" = "yes" ]; then
  printf "${RED}Here is a list of calibre library files that you can select with the option "-a" (calibre search):${NC}\n\n"
  ls -d $CALIBREPATH/*/* | sed -e "s|$HOME/Calibre/||g" 2>/dev/null
  echo " "
  printf "${RED}Here is a list on MIRANTIS that you can search with the option "-m" (mirantis search):${NC}\n\n"
  ls --color=auto $MIRANTISPATH 2>/dev/null
  echo " "
  printf "${RED}NOTE: You can also use '*' character as a wildcard (example: 'sles*')${NC}\n"
fi
