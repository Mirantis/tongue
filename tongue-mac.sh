#!/bin/bash
set -euo pipefail

# --- Color Definitions ---
RED='\033[0;31m'
NC='\033[0m'

# --- Configuration & Defaults ---
DATE=$(date +"%d-%m-%Y-%H-%M-%S")
export LESSCHARSET="utf-8"

LESS1="less -x4RFWs"
LESS2="less -F -X -R"

LOGPATH="${TONGUE_LOGPATH:-/var/log/tongue}"
BASE_DOCS="${HOME}/Downloads/tongue"
CALIBRE_PATH="${HOME}/calibre"

# --- State Variables ---
SEARCH=""
TARGET_DOC=""
SUBTARGET=""
CASE_INSENSITIVE=1
SHOW_HELP=0
SHOW_LIST=0

# macOS prefers ggrep if available via Homebrew
if command -v ggrep &>/dev/null; then
  GREP="ggrep"
else
  GREP="grep"
fi

# --- Helper Functions ---
check_dependencies() {
  local missing=()
  for cmd in rg pdfgrep "$GREP"; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("$cmd")
    fi
  done

  if [ ${#missing[@]} -ne 0 ]; then
    echo "Missing required dependency/dependencies on macOS: ${missing[*]}"
    if command -v brew &>/dev/null; then
      echo "Installing missing packages via Homebrew..."
      brew install "${missing[@]}"
    else
      echo "Homebrew is not installed. Please install missing packages manually and re-run."
      exit 1
    fi
  fi
}

ensure_log_dir() {
  if [ ! -d "$LOGPATH" ]; then
    echo "Seems like you are running tongue for the first time. We need permissions to create $LOGPATH."
    if ! mkdir -p "$LOGPATH" 2>/dev/null; then
      sudo mkdir -p "$LOGPATH"
      sudo chown "$USER" "$LOGPATH"
    fi
  fi
  find "$LOGPATH" -type f -mtime +60 -exec rm -f {} + 2>/dev/null || true
}

show_help() {
  cat << 'EOF'
Usage (macOS): tongue-mac.sh [OPTIONS] -s SEARCH_STRING

Options:
  -a, --calibre AUTHOR       Search Calibre PDF library (~/calibre)
  -b, --rabbitmq SUBDIR      Search RabbitMQ documentation (.md)
  -c, --ceph SUBDIR          Search Ceph documentation (.rst)
  -d, --docker-ent SUBDIR    Search Docker Enterprise documentation (.md)
  -e, --openstack SUBDIR     Search OpenStack documentation (.rst)
  -f, --prometheus SUBDIR    Search Prometheus documentation (.md)
  -g, --k0rdent SUBDIR       Search k0rdent documentation (.md)
  -j, --calico SUBDIR        Search Calico documentation (.mdx)
  -k, --kubernetes SUBDIR    Search Kubernetes documentation (.md)
  -m, --mirantis SUBDIR      Search Mirantis documentation (.rst)
  -n, --kernel SUBDIR        Search Linux Kernel documentation (.rst)
  -o, --helm SUBDIR          Search Helm documentation (.md)
  -p, --mariadb SUBDIR       Search MariaDB documentation (.pdf)
  -q, --tungsten SUBDIR      Search Tungsten Fabric documentation (.rst)
  -t, --cloud-init SUBDIR    Search Cloud-Init documentation (.html)
  -u, --ubuntu SUBDIR        Search Ubuntu documentation (.md)
  -y, --systemd SUBDIR       Search systemd documentation (.html)
  -s, --search QUERY         Search query string
  -i, --case-sensitive      Enable case-sensitive search
  -l, --list                 List available documentation subdirectories
  -h, --help                 Display this help message
EOF
}

get_doc_meta() {
  case "$1" in
    calibre)    echo "pdf|Calibre Library|${CALIBRE_PATH}|s|${CALIBRE_PATH}|file://${CALIBRE_PATH}|g" ;;
    rabbitmq)   echo "md|RabbitMQ|${BASE_DOCS}/www.rabbitmq.com/docs|s|${BASE_DOCS}/|https://|g; s/\.md/\.html/g" ;;
    ceph)       echo "rst|Ceph|${BASE_DOCS}/docs.ceph.com/doc|s|${BASE_DOCS}/|https://|g; s/\.rst/\//g; s|/doc/|/en/latest/|g; s|/index/||g" ;;
    docker-ent) echo "md|Docker Enterprise|${BASE_DOCS}/docs.docker.com/content|s|${BASE_DOCS}/|https://|g; s/\.md/\//g; s;content/;;g; s;_index;;g; s;/manuals;;g; s;//;/;g" ;;
    openstack)  echo "rst|OpenStack|${BASE_DOCS}/docs.openstack.org|s|${BASE_DOCS}/|https://|g; s/\.rst/\.html /g; s;/doc/source/;/latest/;g; s;README\.html;;g" ;;
    prometheus) echo "md|Prometheus|${BASE_DOCS}/prometheus.io/content/docs|s|${BASE_DOCS}/|https://|g; s/\.md/\//g; s;/content;;g" ;;
    k0rdent)    echo "md|k0rdent|${BASE_DOCS}/github.com/k0rdent/docs|s|${BASE_DOCS}/github\.com/k0rdent/docs/docs|https://docs.k0rdent-enterprise.io/latest|g; s/\.md/\//g" ;;
    calico)     echo "mdx|Calico|${BASE_DOCS}/docs.tigera.io/calico|s|${BASE_DOCS}/|https://|g; s/\.mdx/\//g; s;/calico;/calico/latest;g; s;/index/||g" ;;
    kubernetes) echo "md|Kubernetes|${BASE_DOCS}/kubernetes.io/content/en|s|${BASE_DOCS}/|https://|g; s/\.md/\.html/g; s;/content/en/;;g; s;_index\.html;index\.html;g" ;;
    mirantis)   echo "rst|Mirantis|${BASE_DOCS}/docs.mirantis.com|s|${BASE_DOCS}/|https://|g; s/\.rst/\.html /g; s;/doc/source;;g; s;/openstack-docs;;g; s;/kaas-docs;;g; s;/mke-docs;;g; s;/mcr-docs;;g" ;;
    kernel)     echo "rst|Linux Kernel|${BASE_DOCS}/docs.kernel.org/Documentation|s|${BASE_DOCS}/|https://|g; s/\.rst/\.html /g; s;/Documentation;;g" ;;
    helm)       echo "md|Helm|${BASE_DOCS}/helm.sh/content/en/docs|s|${BASE_DOCS}/|https://|g; s/\.md/\.html/g; s|/content/en||g" ;;
    mariadb)    echo "pdf|MariaDB|${BASE_DOCS}/mariadb|s|${BASE_DOCS}/mariadb|file://${BASE_DOCS}/mariadb|g" ;;
    tungsten)   echo "rst|Tungsten Fabric|${BASE_DOCS}/github.com/OpenSDN-io/docs|s|${BASE_DOCS}/|https://|g; s/\.rst/\.rst /g; s;/docs;/docs/tree/master;g" ;;
    cloud-init) echo "html|Cloud-Init|${BASE_DOCS}/cloudinit.readthedocs.io/en/latest|s|${BASE_DOCS}/|https://|g" ;;
    ubuntu)     echo "md|Ubuntu Server|${BASE_DOCS}/documentation.ubuntu.com/server|s|${BASE_DOCS}/|https://|g; s/\.md/\//g" ;;
    systemd)    echo "html|systemd|${BASE_DOCS}/systemd.io|s|${BASE_DOCS}/|https://|g" ;;
    *)          echo "" ;;
  esac
}

show_documentation_list() {
  local targets=("calibre" "rabbitmq" "ceph" "docker-ent" "openstack" "prometheus" "calico" "kubernetes" "mirantis" "kernel" "helm" "mariadb" "tungsten" "cloud-init" "ubuntu" "systemd")
  for key in "${targets[@]}"; do
    IFS='|' read -r ext name path sed_expr <<< "$(get_doc_meta "$key")"
    printf "${RED}Available targets for %s:${NC}\n" "$name"
    if [ "$key" = "calibre" ]; then
      ls -d "$path"/*/* 2>/dev/null | sed -e "s|$HOME/Calibre/||g" || true
    elif [ "$key" = "cloud-init" ]; then
      ls --color=auto "$path"/*/ 2>/dev/null | sed -e "s|$HOME/Downloads/tongue/cloudinit.readthedocs.io/en/latest/topics||g" || true
    elif [ -d "$path" ]; then
      ls --color=auto "$path" 2>/dev/null || true
    else
      echo "  Directory not found: $path"
    fi
    echo ""
  done
  printf "${RED}NOTE: You can also use '*' character as a wildcard (example: 'sles*')${NC}\n"
}

execute_search() {
  local target_key="$1"
  local sub_path="$2"
  local query="$3"

  IFS='|' read -r file_ext name search_path transform_sed <<< "$(get_doc_meta "$target_key")"

  local full_target="${search_path}/${sub_path}"
  
  if [ -z "$sub_path" ] && [ -z "$query" ]; then
    echo "$name field and search field are empty. Possible values are:"
    ls --color=auto "$search_path" 2>/dev/null || true
    exit 1
  elif [ -z "$sub_path" ]; then
    echo "$name field is empty. Possible values are:"
    ls --color=auto "$search_path" 2>/dev/null || true
    exit 1
  elif [ -z "$query" ]; then
    echo "Search field is empty. Add -s <search> to start searching."
    exit 1
  fi

  echo "Searching for '$query' on $name pages for '$sub_path'. Please wait"

  local results_file="${LOGPATH}/tongue-results-${DATE}"
  local report_file="${LOGPATH}/tongue-reports"
  local match_file="${LOGPATH}/tongue-urls-match"

  local case_flag=""
  local rg_case_flag="-i"
  if [ "$CASE_INSENSITIVE" -eq 0 ]; then
    case_flag=""
    rg_case_flag=""
  else
    case_flag="-i"
    rg_case_flag="-i"
  fi

  if [ "$file_ext" = "pdf" ]; then
    pdfgrep -rcH $case_flag "$query" $full_target 2>/dev/null | $GREP -v ':0' | sed -e 's/pdf:/pdf :/g' > "$match_file" || true
    local url_count
    url_count=$(wc -l < "$match_file")
    
    if [ "$url_count" -eq 0 ]; then
      echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
      exit 1
    fi

    printf "${RED}----------------- [%s PDF SEARCH RESULTS] -----------------${NC}\n" "$name" > "$results_file"
    pdfgrep -rnH --color=always $case_flag "$query" $full_target 2>/dev/null | \
      sed -e "$transform_sed" -e "s| (|\%20(|g" -e "s| - |\%20-\%20|g" -e "s,\.pdf\x1B\[m\x1B\[K\x1B\[36m\x1B\[K\:,\.pdf\x1B\[m\x1B\[K\x1B\[36m\x1B\[K\#page\=,g" -e "s,\x1B\[m\x1B\[K\x1B\[36m\x1B\[K\:,\x1B\[m\x1B\[K\x1B\[36m\x1B\[K \:,g" >> "$results_file"
  else
    rg $rg_case_flag -g "*.$file_ext" -l "$query" $full_target 2>/dev/null | $GREP -v ':0' > "$match_file" || true
    local url_count
    url_count=$(wc -l < "$match_file")

    if [ "$url_count" -eq 0 ]; then
      echo "Search not found. Make sure the fields are correctly filled. Run 'tongue -h' for help."
      exit 1
    fi

    printf "${RED}----------------- [%s DOCUMENTATION SEARCH RESULTS] -----------------${NC}\n" "$name" > "$results_file"
    rg $rg_case_flag -g "*.$file_ext" "$query" $full_target 2>/dev/null | \
      sed -e "$transform_sed" >> "$results_file"
  fi

  $LESS1 "$results_file"

  echo " "
  printf "${RED}----------------- [%s DOCUMENTATION SEARCH REPORT] -----------------${NC}\n" "$name" > "$report_file"
  printf "The term '${RED}%s${NC}' was found on ${RED}%s${NC} page(s):\n" "$query" "$url_count" >> "$report_file"
  cat "$match_file" >> "$report_file"

  sed "$transform_sed" "$report_file" | sort -n -t ':' -k3n,3n | $LESS2

  echo " "
  echo "The search results were saved to $results_file"
  echo " "
}

# --- Command Line Argument Processing ---
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--calibre)          TARGET_DOC="calibre"; SUBTARGET="$2"; shift 2 ;;
    -b|--rabbitmq)         TARGET_DOC="rabbitmq"; SUBTARGET="$2"; shift 2 ;;
    -c|--ceph)             TARGET_DOC="ceph"; SUBTARGET="$2"; shift 2 ;;
    -d|--docker-enterprise) TARGET_DOC="docker-ent"; SUBTARGET="$2"; shift 2 ;;
    -e|--openstack)        TARGET_DOC="openstack"; SUBTARGET="$2"; shift 2 ;;
    -f|--prometheus)       TARGET_DOC="prometheus"; SUBTARGET="$2"; shift 2 ;;
    -g|--k0rdent)          TARGET_DOC="k0rdent"; SUBTARGET="$2"; shift 2 ;;
    -j|--calico)           TARGET_DOC="calico"; SUBTARGET="$2"; shift 2 ;;
    -k|--kubernetes)       TARGET_DOC="kubernetes"; SUBTARGET="$2"; shift 2 ;;
    -m|--mirantis)         TARGET_DOC="mirantis"; SUBTARGET="$2"; shift 2 ;;
    -n|--kernel)           TARGET_DOC="kernel"; SUBTARGET="$2"; shift 2 ;;
    -o|--helm)             TARGET_DOC="helm"; SUBTARGET="$2"; shift 2 ;;
    -p|--mariadb)          TARGET_DOC="mariadb"; SUBTARGET="$2"; shift 2 ;;
    -q|--tungsten)         TARGET_DOC="tungsten"; SUBTARGET="$2"; shift 2 ;;
    -t|--cloud-init)       TARGET_DOC="cloud-init"; SUBTARGET="$2"; shift 2 ;;
    -u|--ubuntu)           TARGET_DOC="ubuntu"; SUBTARGET="$2"; shift 2 ;;
    -y|--systemd)          TARGET_DOC="systemd"; SUBTARGET="$2"; shift 2 ;;
    -s|--search)           SEARCH="$2"; shift 2 ;;
    -i|--case-sensitive)   CASE_INSENSITIVE=0; shift ;;
    -l|--list)             SHOW_LIST=1; shift ;;
    -h|--help)             SHOW_HELP=1; shift ;;
    *) echo "Unknown option: $1"; show_help; exit 1 ;;
  esac
done

check_dependencies
ensure_log_dir

if [ "$SHOW_HELP" -eq 1 ]; then
  show_help
  exit 0
fi

if [ "$SHOW_LIST" -eq 1 ]; then
  show_documentation_list
  exit 0
fi

if [ -n "$TARGET_DOC" ]; then
  execute_search "$TARGET_DOC" "$SUBTARGET" "$SEARCH"
else
  echo "No target documentation selected. Run 'tongue-mac.sh -h' for help."
  exit 1
fi
