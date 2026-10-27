#!/bin/bash
# WCOSS2-specific module setup.

if command -v module >/dev/null 2>&1; then
  module load python/3.8.6
  module use /lfs/h1/mdl/nbm/save/apps/modulefiles
  module load python-modules/3.8.6
fi

export AM4WMO_MACHINE="wcoss2"
