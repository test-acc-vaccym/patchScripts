#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2013 Mateor
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# order builds for SlimRom, CyanogenMod, AOKP, AOSP, PAC-man, OmniRom, ParanoidAndroid and whomever else.

# adjust these to your own environment/preferences
ANDROID_HOME=~/android/system/jellybean
# PDROID_LOC generally will be where you git clone patchScripts
PDROID_LOC=~/android/openpdroid
TARGET=mako

# adjust as per your machine- 8 might be a good start.
JOBS=24

TARGET_VERSION=4.4
LUNCH_COMMAND="lunch ${1}_${TARGET}-userdebug"

# If you want the whole rom, change this to something else ("make otapackage" or "brunch $TARGET" maybe).
BUILD_COMMAND=$PDROID_LOC/makeOPDFiles.sh

print_error() {
     echo ""
     echo "!!! error: $@ !!!"
     echo ""
     echo "Your build was not ordered correctly"
     echo ""
}

if [[ $# -gt 1 ]]; then
     TARGET_VERSION="$2"
fi

# Perhaps one day to be expanded to take 'files to place' as a second parameter.
if [[ $# -lt 1 ]]; then
     echo ""
     echo "### Error ###"
     echo ""
     echo "You must indicate what the romtype and Android version is."
     echo ""
     echo " Usage is"
     echo "./orderBuilds cm 4.3"
     echo "   or"
     echo "./orderBuilds aosp 4.4"
     echo ""
     echo "Supported options are ${ROM_OPTIONS[@]}"
     exit
fi

case "$1" in
     aosp)
          GITHUB=android/platform_manifest
          case "$TARGET_VERSION" in
               4.0)
               TARGET_BRANCH=android-4.0.4_r2
               ;;
               4.1)
               TARGET_BRANCH=android-4.1.2_r2.1
               ;;
               4.2)
               TARGET_BRANCH=android-4.2.2_r1.2
               ;;
               4.3)
               TARGET_BRANCH=android-4.3_r3
               ;;
               4.4)
               TARGET_BRANCH=android-4.4_r1.1
               ;;
          esac
     ;;
     cm)
          GITHUB=CyanogenMod/android
          case "$TARGET_VERSION" in
               4.0)
               TARGET_BRANCH=ics
               ;;
               4.1)
               TARGET_BRANCH=jellybean
               ;;
               4.2)
               TARGET_BRANCH=cm-10.1
               ;;
               4.3)
               TARGET_BRANCH=cm-10.2
               ;;
               4.4)
               TARGET_BRANCH=cm-11.0
               ;;
          esac
     ;;
     aokp)
          GITHUB=AOKP/platform_manifest
          case "$TARGET_VERSION" in
               4.0)
               TARGET_BRANCH=ics
               ;;
               4.1)
               TARGET_BRANCH=jb
               ;;
               4.2)
               TARGET_BRANCH=jb-mr1
               ;;
               4.3)
               TARGET_BRANCH=jb-mr2
               ;;
               4.4)
               TARGET_BRANCH=kitkat
               ;;
          esac
     ;;
     slim)
          GITHUB=SlimRoms/platform_manifest
          case "$TARGET_VERSION" in
               4.1)
               TARGET_BRANCH=jb
               ;;
               4.2)
               TARGET_BRANCH=jb4.2
               ;;
               4.3)
               TARGET_BRANCH=jb4.3
               ;;
               4.4)
               TARGET_BRANCH=kk4.4
               ;;
          esac
     ;;
     pa)
          GITHUB=ParanoidAndroid/manifest
          case "$TARGET_VERSION" in
               4.2)
               TARGET_BRANCH=jellybean
               ;;
               4.3)
               TARGET_BRANCH=jb43
               ;;
               4.4)
               TARGET_BRANCH=kk4.4
               ;;
          esac
     ;;
     pac)
          GITHUB=PAC-man/android
          case "$TARGET_VERSION" in
               4.1)
               TARGET_BRANCH=jellybean
               ;;
               4.2)
               TARGET_BRANCH=cm-10.1
               ;;
               4.3)
               TARGET_BRANCH=cm-10.2
               ;;
               4.4)
               TARGET_BRANCH=cm-11.0
               ;;
          esac
     ;;
     omni)
          GITHUB=PAC-man/android
          case "$TARGET_VERSION" in
               4.3)
               TARGET_BRANCH=android-4.3
               ;;
               4.4)
               TARGET_BRANCH=android-4.4
               ;;
          esac
     ;;
     http*)
          GITHUB="$1"
          TARGET_BRANCH="$TARGE_VERSION"
          # This is just for a start b/c it will be trouble when swicthing between romtypes. Use unset?
          LUNCH_COMMAND=brunch $TARGET
     ;;
     *)
     print_error "Not a valid rom target."
     ;;
esac


# order builds
cd "$ANDROID_HOME"
rm -rf .repo/manifests manifests.xml
rm -rf .repo/local_manifests local_manifests.xml
repo init -u https://github.com/${GITHUB} -b $TARGET_BRANCH
repo sync -j${JOBS} -f
. build/envsetup.sh
$LUNCH_COMMAND
$BUILD_COMMAND