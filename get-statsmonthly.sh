#!/bin/bash
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

begin=$(ndate -24)
beg=${begin:0:8}
nyear=${beg:0:4}
nmonth=${beg:4:6}
namemonth=$(date -u -d "${nyear}-${nmonth}-01" +"%B")

WORKDIR="${WORKDIR:-${MONAIRCFT_ROOT}}"
WORKDIRSRC="${WORKDIRSRC:-${AM4WMO_ROOT}/pscripts}"
DATA_DIR="${DATA_DIR:-${AM4WMO_DATA_ROOT}/$nmonth}"
HEADER_DIR="${HEADER_DIR:-${AM4WMO_ROOT}/fix}"

cd "$WORKDIR" || exit 1

if [ ! -d "$DATA_DIR" ]; then
  echo "Missing monthly data directory: $DATA_DIR" >&2
  exit 1
fi

cd "$DATA_DIR" || exit 1

# Keep only recent files; remove older ones from the monthly data dir.
find "$DATA_DIR" -type f -mtime +336 -delete 2>/dev/null || true

# Build combined monthly files only when matching daily files exist.
for pattern in d131-t* d133-t* d133-q* d231-w* d233-w*; do
  if [ ! -e "$pattern" ]; then
    echo "Missing files for pattern: $pattern" >&2
    exit 1
  fi
done

cat d131-t* | grep -v obstype > dx1
cat "$HEADER_DIR/headert.txt" dx1 > tdaily131.csv

cat d133-t* | grep -v obstype > dx1
cat "$HEADER_DIR/headert.txt" dx1 > tdaily133.csv

cat d133-q* | grep -v obstype > dx1
cat "$HEADER_DIR/headerq.txt" dx1 > qdaily133.csv

cat d231-w* | grep -v obstype > dx1
cat "$HEADER_DIR/headerw.txt" dx1 > wdaily231.csv

cat d233-w* | grep -v obstype > dx1
cat "$HEADER_DIR/headerw.txt" dx1 > wdaily233.csv

rm -f dx1

## script to read input files, cumulate data and produce statistics by aircraft tailnumber
python "$WORKDIRSRC/tsums.py" 131
python "$WORKDIRSRC/tsums.py" 133
python "$WORKDIRSRC/wsums.py" 231
python "$WORKDIRSRC/wsums.py" 233
python "$WORKDIRSRC/qsums.py" 133

# now calculate suspects
python "$WORKDIRSRC/q133acars-stats.py" "$namemonth" "$nyear"
python "$WORKDIRSRC/t133acars-stats.py" "$namemonth" "$nyear"
python "$WORKDIRSRC/w233acars-stats.py" "$namemonth" "$nyear"

python "$WORKDIRSRC/w231suspect.py" "$namemonth" "$nyear"
python "$WORKDIRSRC/t131suspect.py" "$namemonth" "$nyear"

python "$WORKDIRSRC/w233suspect.py" "$namemonth" "$nyear"
python "$WORKDIRSRC/t133suspect.py" "$namemonth" "$nyear"

#putting reports together
echo "            ACAR Statistics Versus the NCEP Guess" > acarspom1
echo "               " "$namemonth" "$nyear" > pom2
tail -n +3 wacar-stats.txt > w233pom3
cat acarspom1 pom2 "$WORKDIRSRC/src/acarswnd.txt" w233pom3 > /lfs/h2/emc/obsproc/noscrub/dagmar.merkova/WMO_MONITOR/acarswnd.${nyear}${nmonth}.txt

tail -n +3 tacar-stats.txt > t133pom3
cat acarspom1 pom2 "$WORKDIRSRC/src/acarstmp.txt" t133pom3 > /lfs/h2/emc/obsproc/noscrub/dagmar.merkova/WMO_MONITOR/acarstmp.${nyear}${nmonth}.txt

tail -n +3 qacar-stats.txt > q133pom3
cat acarspom1 pom2 "$WORKDIRSRC/src/acarsmst.txt" q133pom3 > /lfs/h2/emc/obsproc/noscrub/dagmar.merkova/WMO_MONITOR/acarsmst.${nyear}${nmonth}.txt

tail -n +3 acar.txt > t133pom3
tail -n +3 wacar.txt > w233pom3
cat acarspom1 pom2 "$WORKDIRSRC/src/acarsstd.txt" t133pom3 w233pom3 > /lfs/h2/emc/obsproc/noscrub/dagmar.merkova/WMO_MONITOR/acarsstd.${nyear}${nmonth}.txt

echo "            AMDAR Statistics Versus the NCEP Guess" > amdarspom1
echo "               " "$namemonth" "$nyear" > pom2
tail -n +3 amdar.txt > t131pom3
tail -n +3 wamdar.txt > w231pom3
cat amdarspom1 pom2 "$WORKDIRSRC/src/amdars.txt" t131pom3 w231pom3 > /lfs/h2/emc/obsproc/noscrub/dagmar.merkova/WMO_MONITOR/amdar.${nyear}${nmonth}.txt

echo "DONE"
