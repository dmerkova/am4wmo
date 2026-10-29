#!/bin/bash
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"
PYTHON_SCRIPT="${SCRIPT_DIR}/pscripts/daily_stats.py"

# Optional filters: default = all three types.
# Examples:
#   ./get-statsdaily.sh --temp
#   ./get-statsdaily.sh --wind --humidity
#   ./get-statsdaily.sh --type temp --type wind
#   ./get-statsdaily.sh --begin 2024060100 --end 2024060300
TYPES=()
BEGIN_DATE=""
END_DATE=""

utc_dt() {
  local dt="$1"
  printf '%s-%s-%s %s:00:00 UTC' "${dt:0:4}" "${dt:4:2}" "${dt:6:2}" "${dt:8:2}"
}

step_dt() {
  local dt="$1"
  local hours="$2"
  date -u -d "$(utc_dt "$dt") ${hours} hours" +%Y%m%d%H
}

while [ $# -gt 0 ]; do
  case "$1" in
    --temp|-t)
      TYPES+=(temp)
      ;;
    --wind|-w)
      TYPES+=(wind)
      ;;
    --humidity|--humid|-q)
      TYPES+=(humidity)
      ;;
    --type)
      if [ $# -lt 2 ]; then
        echo "Missing value for --type" >&2
        exit 1
      fi
      TYPES+=("$2")
      shift
      ;;
    --begin|--start)
      if [ $# -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 1
      fi
      BEGIN_DATE="$2"
      shift
      ;;
    --end|--stop)
      if [ $# -lt 2 ]; then
        echo "Missing value for $1" >&2
        exit 1
      fi
      END_DATE="$2"
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [--temp|--wind|--humidity] [--type temp] [--begin YYYYMMDDHH] [--end YYYYMMDDHH]"
      echo "Default: process the previous UTC day (24 hours) when begin/end are omitted."
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

# If the user did not select any type, run all.
if [ ${#TYPES[@]} -eq 0 ]; then
  TYPES=(temp wind humidity)
fi

# Deduplicate while preserving order.
declare -A seen=()
SELECTED=()
for item in "${TYPES[@]}"; do
  if [ -z "${seen[$item]+x}" ]; then
    seen["$item"]=1
    SELECTED+=("$item")
  fi
done

if [ -n "$BEGIN_DATE" ] && [ -n "$END_DATE" ] && [ "$(date -u -d "$(utc_dt "$BEGIN_DATE")" +%s)" -gt "$(date -u -d "$(utc_dt "$END_DATE")" +%s)" ]; then
  echo "Error: --begin must be earlier than or equal to --end" >&2
  exit 1
fi

if [ -z "$BEGIN_DATE" ] && [ -z "$END_DATE" ]; then
  BEGIN_DATE="$(date -u -d '1 day ago' +%Y%m%d00)"
  END_DATE="$(step_dt "$BEGIN_DATE" 24)"
elif [ -n "$BEGIN_DATE" ] && [ -z "$END_DATE" ]; then
  END_DATE="$(step_dt "$BEGIN_DATE" 24)"
elif [ -z "$BEGIN_DATE" ] && [ -n "$END_DATE" ]; then
  BEGIN_DATE="$(step_dt "$END_DATE" -24)"
fi

i="$BEGIN_DATE"
WORK_DIR="${WORK_DIR:-${HOME}/am4wmo-diag-stats-$(date -u +%Y%m%d%H%M%S)}"
export DIAGFILES="${DIAGFILES:-${WORK_DIR}/diagfiles}"
mkdir -p "$DIAGFILES"
cd "$WORK_DIR" || exit 1

while [ "$(date -u -d "$(utc_dt "$i")" +%s)" -le "$(date -u -d "$(utc_dt "$END_DATE")" +%s)" ]; do
  echo "Processing $i"

  datum="${i:0:8}"
  hh="${i:8:2}"
  src="/lfs/h1/ops/prod/com/gfs/v16.3/gdas.${datum}/${hh}/atmos/gdas.t${hh}z.cnvstat"
  alt_src="/lfs/h2/emc/ptmp/dagmar.merkova/gdas.${datum}/${hh}/atmos/gdas.t${hh}z.cnvstat"

  if [ -f "$src" ]; then
    src="$src"
  elif [ -f "$alt_src" ]; then
    src="$alt_src"
  else
    echo "Missing production diag archive: $src or $alt_src" >&2
    exit 1
  fi

  cp -f "$src" "$DIAGFILES/"
  tar -xvf "$DIAGFILES/gdas.t${hh}z.cnvstat" -C "$DIAGFILES/" \
    "diag_conv_t_ges.${datum}${hh}.nc4.gz" \
    "diag_conv_uv_ges.${datum}${hh}.nc4.gz" \
    "diag_conv_q_ges.${datum}${hh}.nc4.gz"
  gunzip -f "$DIAGFILES/diag_conv_t_ges.${datum}${hh}.nc4.gz" \
    "$DIAGFILES/diag_conv_uv_ges.${datum}${hh}.nc4.gz" \
    "$DIAGFILES/diag_conv_q_ges.${datum}${hh}.nc4.gz"

  ARGS=(--date "$i")
  for kind in "${SELECTED[@]}"; do
    ARGS+=(--type "$kind")
  done

  python "$PYTHON_SCRIPT" "${ARGS[@]}"

  rm -f "$DIAGFILES/gdas.t${hh}z.cnvstat" \
        "$DIAGFILES/diag_conv_t_ges.${datum}${hh}.nc4" \
        "$DIAGFILES/diag_conv_uv_ges.${datum}${hh}.nc4" \
        "$DIAGFILES/diag_conv_q_ges.${datum}${hh}.nc4"

  i="$(step_dt "$i" 6)"
done

rm -f "$DIAGFILES"/*.tar "$DIAGFILES"/*.gz "$DIAGFILES"/*.nc4 2>/dev/null || true
rmdir "$DIAGFILES" 2>/dev/null || true

