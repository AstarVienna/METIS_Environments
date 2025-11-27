#!/usr/bin/env bash
set -Eeuo pipefail

# Allow ** to match any amount of subdirectories with globstar.
shopt -s globstar

echo "Executing METIS Pipeline end-to-end tests. Simulation - Pipeline - Archive."

echo "Setup."

echo "Remove database-is-ready control flag."
FN_CONTROL_DATABASE_READY="${HOME}/space/control/database_setup"
if [ -f "${FN_CONTROL_DATABASE_READY}" ] ; then
  rm "${FN_CONTROL_DATABASE_READY}"
fi

echo "Updating Repositories, they can be old in the container image."
pushd "${HOME}/repos"
REPODIRS=$(find . -mindepth 1 -maxdepth 1 -type d)
for REPOD in $REPODIRS ; do
  git -C "${REPOD}" pull
done
popd

echo "Setting up database."
mkdir -p "${HOME}/space/control/"

echo "Becoming system user."
source "${HOME}/repos/MetisWISE/toolbox/become_system_user.sh"

echo "Waiting until the database has started."
while true ; do
  if psql "postgres://${database_user}:${database_password}@${database_name}" -p "${database_port}" -c "select version();" -x ; then
    echo "Database found!"
    break
  fi
  echo "Database not yet found, sleeping."
  sleep 1
done

echo "Initializing database."
python "${HOME}/repos/MetisWISE/metiswise/tools/dbtestsetup.py"

echo "Become normal user again."
source "${HOME}/repos/MetisWISE/toolbox/become_normal_user.sh"

echo "Telling the dbviewer it can start."
touch "${FN_CONTROL_DATABASE_READY}"

echo "Testing the ingestion of a file."
pushd "${HOME}/scripts"
python storefile.py
curl -k https://dataserver:8013/testfile.txt
popd

echo "Check ESO tools."
echo "Can we run recipes?"
pyesorex --recipes

echo "Starting the edps by listing workflows."
edps -lw

echo "Preparing simulations."
pushd "${HOME}/repos/METIS_Simulations/Simulations"
echo "Create output directory."
mkdir -p "${HOME}/space/raw"
# TODO: check whether these links already exist before making them.
echo "Link the output directory so the files are on the host."
ln -s "${HOME}/space/raw" output || true
echo "Link the IRDB so nothing has to be downloaded."
ln -s "${HOME}/repos/irdb" inst_pkgs || true
echo "Running simulations."
python3 "python/imgN.py"
#python3 "python/ifu.py"
#python3 "python/testAll.py"
#./runESO.sh
popd
echo "TODO: Add more simulations."

echo "Classify data with the EDPS"
edps -w metis.metis_wkf -i "${HOME}/space/raw" -c

echo "Ingesting raw data into the archive"
# Using find is a bit slow, because of the startup costs.
#find "${HOME}"/space/raw -name "*.fits" -exec \
#  python "${HOME}/repos/MetisWISE/metiswise/tools/ingest_file.py" {} \;
python "${HOME}/repos/MetisWISE/metiswise/tools/ingest_file.py" "${HOME}"/space/raw/**/*.fits


echo "Process data with the EDPS"
mkdir -p "${HOME}/space/processed"
edps -w metis.metis_wkf -m all -i "${HOME}/space/raw" -o "${HOME}/space/processed"
# TODO: remove target
#edps -w metis.metis_wkf -m all -i "${HOME}/space/raw" -o "${HOME}/space/processed" -t metis_ifu_dark
# TODO: figure out how to move the files.

echo "Ingesting processed data into the archive"
# TODO: These filenames are not unique at all, so this won't work as intended.
# TODO: This is currently broken, it errors out with
python "${HOME}/repos/MetisWISE/metiswise/tools/ingest_file.py" "${HOME}"/space/processed/**/*.fits

echo "Stay a while... stay forever!"
while true; do sleep 60 ; done
