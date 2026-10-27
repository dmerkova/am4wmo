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
TYPES=()
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
    -h|--help)
      echo "Usage: $0 [--temp|--wind|--humidity] [--type temp] ..."
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

begin=$(ndate -24)
beg=${begin:0:8}
i="${beg}00"
end=$(ndate 24 "$i")
WORK_DIR="${WORK_DIR:-${HOME}/am4wmo-diag-stats-$(date -u +%Y%m%d%H%M%S)}"
export DIAGFILES="${DIAGFILES:-${WORK_DIR}/diagfiles}"
mkdir -p "$DIAGFILES"
cd "$WORK_DIR" || exit 1

while [ "$i" -le "$end" ]; do
  echo "Processing $i"

  datum="${i:0:8}"
  hh="${i:8:2}"
  src="/lfs/h1/ops/prod/com/gfs/v16.3/gdas.${datum}/${hh}/atmos/gdas.t${hh}z.cnvstat"

  if [ ! -f "$src" ]; then
    echo "Missing production diag archive: $src" >&2
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

  i=$((i + 6))
done

rm -f "$DIAGFILES"/*.tar "$DIAGFILES"/*.gz "$DIAGFILES"/*.nc4 2>/dev/null || true
rmdir "$DIAGFILES" 2>/dev/null || true

