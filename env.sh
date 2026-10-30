#!/bin/bash
# Common AM4WMO environment defaults.
# Machine-specific settings are loaded from env.hera.sh or env.wcoss2.sh.

AM4WMO_ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export AM4WMO_ROOT

export MONAIRCFT_ROOT="${MONAIRCFT_ROOT:-/lfs/h2/emc/obsproc/noscrub/dagmar.merkova/MONaircft}"
case "$(hostname)" in
  *wcoss*|*WCOSS*|*dlogin*|*login*|*cactus*)
    export STMP="${STMP:-/lfs/h2/emc/stmp/${USER:-$(whoami)}}"
    ;;
  *)
    export STMP="${STMP:-${TMPDIR:-/tmp}}"
    ;;
 esac
export WORKDIR="${WORKDIR:-$MONAIRCFT_ROOT}"
export AM4WMO_DATA_ROOT="${AM4WMO_DATA_ROOT:-${MONAIRCFT_ROOT}/data}"
export NDATE="${NDATE:-/apps/ops/prod/nco/core/prod_util.v2.0.14/exec/ndate}"
export AM4WMO_MACHINE="${AM4WMO_MACHINE:-$(uname -n)}"

# Generic Python path used by all scripts.
COMMON_PYTHONPATH="/lfs/h1/mdl/nbm/save/apps/python-modules/apps/spack/python/3.8.6/intel/19.1.3.304/pjn2nzkjvqgmjw4hmyz43v5x4jbxjzpk/lib/python3.8/site-packages:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/py-ncepbufr:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/pandas:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/py-ncepbufr/:/lfs/h2/emc/da/noscrub/dagmar.merkova/git/NCEPLIBS-bufr/python/ncepbufr:/u/dagmar.merkova/.local/lib/python3.6/site-packages"
export PYTHONPATH="${PYTHONPATH:+${PYTHONPATH}:}${COMMON_PYTHONPATH}"

case "$(hostname)" in
  *hera*|*HERA*)
    source "$AM4WMO_ROOT/env.hera.sh"
    ;;
  *wcoss*|*WCOSS*|*dlogin*|*login*|*cactus*)
    source "$AM4WMO_ROOT/env.wcoss2.sh"
    ;;
  *)
    echo "AM4WMO: environment not configured for host $(hostname). Using generic defaults." >&2
    ;;
esac
