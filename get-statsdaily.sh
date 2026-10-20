#!/bin/bash
set -eu

export NDATE=/apps/ops/prod/nco/core/prod_util.v2.0.14/exec/ndate

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
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

cd "$HOME" || exit 1

module load python/3.8.6
module use /lfs/h1/mdl/nbm/save/apps/modulefiles
module load python-modules/3.8.6

export PYTHONPATH="${PYTHONPATH:+${PYTHONPATH}:}/lfs/h1/mdl/nbm/save/apps/python-modules/apps/spack/python/3.8.6/intel/19.1.3.304/pjn2nzkjvqgmjw4hmyz43v5x4jbxjzpk/lib/python3.8/site-packages:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/py-ncepbufr:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/pandas:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/py-ncepbufr/:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/NCEPLIBS-bufr/python/ncepbufr:/u/dagmar.merkova/.local/lib/python3.6/site-packages"

while [ "$i" -le "$end" ]; do
  echo "Processing $i"

  ARGS=(--date "$i")
  for kind in "${SELECTED[@]}"; do
    ARGS+=(--type "$kind")
  done

  python "$PYTHON_SCRIPT" "${ARGS[@]}"

  i=$((i + 6))
done

