#!/bin/bash

set -e

JDK_VER="17.0.6"
JDK_BUILD="10"
JDK_HASH="824b3c92e8be77f03bdb42b634bd8e00cfd9829603bd817dc06675be6f6761f2"
PACKR_VERSION="runelite-1.7"
PACKR_HASH="f61c7faeaa364b6fa91eb606ce10bd0e80f9adbce630d2bae719aef78d45da61"

SIGNING_IDENTITY="Developer ID Application"

FILE="OpenJDK17U-jre_aarch64_mac_hotspot_${JDK_VER}_${JDK_BUILD}.tar.gz"
URL="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-${JDK_VER}%2B${JDK_BUILD}/${FILE}"

if ! [ -f ${FILE} ] ; then
    curl -Lo ${FILE} ${URL}
fi

echo "${JDK_HASH}  ${FILE}" | shasum -c

# packr requires a "jdk" and pulls the jre from it - so we have to place it inside
# the jdk folder at jre/
if ! [ -d osx-aarch64-jdk ] ; then
    tar zxf ${FILE}
    mkdir osx-aarch64-jdk
    mv jdk-${JDK_VER}+${JDK_BUILD}-jre osx-aarch64-jdk/jre

    pushd osx-aarch64-jdk/jre
    # Move JRE out of Contents/Home/
    mv Contents/Home/* .
    # Remove unused leftover folders
    rm -rf Contents
    popd
fi

if ! [ -f packr_${PACKR_VERSION}.jar ] ; then
    curl -Lo packr_${PACKR_VERSION}.jar \
        https://github.com/runelite/packr/releases/download/${PACKR_VERSION}/packr.jar
fi

echo "${PACKR_HASH}  packr_${PACKR_VERSION}.jar" | shasum -c

java -jar packr_${PACKR_VERSION}.jar \
	packr/macos-aarch64-config.json

cp target/filtered-resources/Info.plist native-osx-aarch64/Eustaria.app/Contents

echo Setting world execute permissions on Eustaria
pushd native-osx-aarch64/Eustaria.app
chmod g+x,o+x Contents/MacOS/Eustaria
popd

codesign -f -s "${SIGNING_IDENTITY}" --entitlements osx/signing.entitlements --options runtime native-osx-aarch64/Eustaria.app || true

# create-dmg exits with an error code due to no code signing, but is still okay
create-dmg native-osx-aarch64/Eustaria.app native-osx-aarch64/ || true

mv native-osx-aarch64/Eustaria\ *.dmg native-osx-aarch64/Eustaria-aarch64.dmg

# Notarize app
if xcrun notarytool submit native-osx-aarch64/Eustaria-aarch64.dmg --wait --keychain-profile "AC_PASSWORD" ; then
    xcrun stapler staple native-osx-aarch64/Eustaria-aarch64.dmg
fi
