#!/bin/bash

# -----
# Usage
# -----
# $ . du.sh <device> <sync|nosync>



# --------
# Examples
# --------
# $ . du.sh angler sync
# $ . du.sh angler nosync



# ----------
# Parameters
# ----------
# Parameter 1: device (eg. angler, bullhead, shamu)
# Parameter 2: sync or nosync (decides whether or not to run repo sync)
DEVICE=$1
SYNC=$2



# ---------
# Variables
# ---------
SOURCEDIR=~/ROMs/DU
OUTDIR=${SOURCEDIR}/out/target/product/${DEVICE}
UPLOADDIR=~/shared/ROMs/"Dirty Unicorns"/${DEVICE}



# ------
# Colors
# ------
BLDRED="\033[1m""\033[31m"
RST="\033[0m"



# Clear the terminal
clear



# Start tracking time
echo -e ${BLDRED}
echo -e "---------------------------------------"
echo -e "SCRIPT STARTING AT $(date +%D\ %r)"
echo -e "---------------------------------------"
echo -e ${RST}

START=$(date +%s)



# Change to the source directory
echo -e ${BLDRED}
echo -e "------------------------------------"
echo -e "MOVING TO ${SOURCEDIR}"
echo -e "------------------------------------"
echo -e ${RST}

cd ${SOURCEDIR}



# Sync the repo if requested
if [ "${SYNC}" == "sync" ]
then
   echo -e ${BLDRED}
   echo -e "----------------------"
   echo -e "SYNCING LATEST SOURCES"
   echo -e "----------------------"
   echo -e ${RST}
   echo -e ""

   repo sync --force-sync
fi



# Setup the build environment
echo -e ${BLDRED}
echo -e "----------------------------"
echo -e "SETTING UP BUILD ENVIRONMENT"
echo -e "----------------------------"
echo -e ${RST}
echo -e ""

. build/envsetup.sh



# Prepare device
echo -e ${BLDRED}
echo -e "----------------"
echo -e "PREPARING DEVICE"
echo -e "----------------"
echo -e ${RST}
echo -e ""

breakfast ${DEVICE}



# Clean up
echo -e ${BLDRED}
echo -e "------------------------------------------"
echo -e "CLEANING UP ${SOURCEDIR}/out"
echo -e "------------------------------------------"
echo -e ${RST}
echo -e ""

make clean
make clobber



# Start building
echo -e ${BLDRED}
echo -e "---------------"
echo -e "MAKING ZIP FILE"
echo -e "---------------"
echo -e ${RST}
echo -e ""

time mka bacon



# Remove exisiting files in UPLOADDIR
echo -e ""
echo -e ${BLDRED}
echo -e "-------------------------"
echo -e "CLEANING UPLOAD DIRECTORY"
echo -e "-------------------------"
echo -e ${RST}

rm "${UPLOADDIR}"/*_${DEVICE}_*.zip
rm "${UPLOADDIR}"/*_${DEVICE}_*.zip.md5sum



# Copy new files to UPLOADDIR
echo -e ${BLDRED}
echo -e "--------------------------------"
echo -e "MOVING FILES TO UPLOAD DIRECTORY"
echo -e "--------------------------------"
echo -e ${RST}

mv ${OUTDIR}/DU_${DEVICE}_*.zip "${UPLOADDIR}"
mv ${OUTDIR}/DU_${DEVICE}_*.zip.md5sum "${UPLOADDIR}"



# Upload the files
echo -e ${BLDRED}
echo -e "---------------"
echo -e "UPLOADING FILES"
echo -e "---------------"
echo -e ${RST}
echo -e ""

. ~/upload.sh



# Clean up out directory to free up space
echo -e ""
echo -e ${BLDRED}
echo -e "------------------------------------------"
echo -e "CLEANING UP ${SOURCEDIR}/out"
echo -e "------------------------------------------"
echo -e ${RST}
echo -e ""

make clean
make clobber



# Go back home
echo -e ${BLDRED}
echo -e "----------"
echo -e "GOING HOME"
echo -e "----------"
echo -e ${RST}

cd ~/



# Stop tracking time
END=$(date +%s)
echo -e ${BLDRED}
echo -e "-------------------------------------"
echo -e "SCRIPT ENDING AT $(date +%D\ %r)"
echo -e ""
echo -e "TIME: $(echo $(($END-$START)) | awk '{print int($1/60)"mins "int($1%60)"secs"}')"
echo -e "-------------------------------------"
echo -e ${RST}
echo -e "\a"
