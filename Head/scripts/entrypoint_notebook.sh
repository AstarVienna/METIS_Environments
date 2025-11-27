#!/usr/bin/env bash
# For some reason .bashrc is skipped.
eval "$(conda shell.bash hook)"
# TODO: use an actual environment
conda activate base
export AWETARGET=metiswise

# TODO: Move to src directory?
#export PYTHONPATH="${HOME}/metiswise:${PYTHONPATH}"

"${HOME}/scripts/print_jupyter_url.sh" &

source "${HOME}/repos/MetisWISE/toolbox/become_normal_user.sh"

jupyter notebook --ip 0.0.0.0 --no-browser --allow-root
