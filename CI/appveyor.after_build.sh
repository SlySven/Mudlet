#!/bin/sh

# This assembles all the files we need into a package sub-directory

echo "Running appveyor.after_build.sh shell script..."
echo ""

if [ ${APPVEYOR_REPO_NAME} != "Mudlet/Mudlet" ] ; then
    # Only run this code on the main Mudlet Github repository - do nothing otherwise:
    echo "This does not appear to be running on the main Mudlet repository, packaging is not appropriate....!"
    echo ""
    exit 0
fi

# Source/setup some variables (including PATH):
. $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/CI/appveyor.set-build-info.sh)

echo "Moving to packaging directory: $(/usr/bin/cygpath --windows ${APPVEYOR_BUILD_FOLDER}/package)"
cd $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/package)
echo "  it contains:"
ls -l
echo ""

# Since Qt 5.14 using the --release switch is broken (it now seems to be
# assumed), --debug still seems to work.
# https://bugreports.qt.io/browse/QTBUG-80806 seems relevant.
echo "Running windeployqt..."
${MINGW_INTERNAL_BASE_DIR}/bin/windeployqt --no-virtualkeyboard mudlet.exe
echo ""

echo "Copying system libraries in..."
if [ "${BUILD_BITNESS}" = "32" ] ; then
    cp -v -p ${MINGW_INTERNAL_BASE_DIR}/bin/libgcc_s_dw2-1.dll .
else
    cp -v -p ${MINGW_INTERNAL_BASE_DIR}/bin/libgcc_s_seh-1.dll .
fi

# To determine which system libraries have to be copied in it requires
# continually trying to run the executable on the target type system
# and adding in the libraries to the same directory and repeating that
# until the executable actually starts to run. Alternatively running
# ldd ./mudlet.exe | grep "/mingw32" {for the 32 bit case, use "64" for
# the other one} inside an Mingw32 (or 64) shell as appropriate will
# produce the libraries that are likely to be needed below. Unfortunetly
# this process is a little recursive in that you may have to repeat the
# process for individual librarys. For ones used by lua modules this
# can manifest as being unable to "require" the library within lua
# and doing the above "ldd" check revealed that "zip.dll" needed
# "libzzip-0-13.dll" and "luasql/sqlite3.dll" needed "libsqlite3-0.dll"!
cp -v -p -t . \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libbrotlicommon.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libbrotlidec.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libbz2-1.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libdouble-conversion.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libfreetype-6.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libglib-2.0-0.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libgraphite2.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libharfbuzz-0.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libhunspell-1.7-0.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libiconv-2.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libicudt67.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libicuin67.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libicuuc67.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libintl-8.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libjasper-4.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libjpeg-8.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/liblzma-5.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libpcre-1.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libpcre2-16-0.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libpng16-16.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libpugixml.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libsqlite3-0.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libstdc++-6.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libtiff-5.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libwebp-7.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libwebpdemux-2.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libwinpthread-1.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libyajl.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libzip.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libzstd.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/libzzip-0-13.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/SDL2.dll \
    ${MINGW_INTERNAL_BASE_DIR}/bin/zlib1.dll

# The openSSL libraries has a different name depending on the bitness:
if [ "${BUILD_BITNESS}" = "32" ] ; then
    cp -v -p -t . \
        ${MINGW_INTERNAL_BASE_DIR}/bin/libcrypto-1_1.dll \
        ${MINGW_INTERNAL_BASE_DIR}/bin/libssl-1_1.dll

else
    cp -v -p -t . \
        ${MINGW_INTERNAL_BASE_DIR}/bin/libcrypto-1_1-x64.dll \
        ${MINGW_INTERNAL_BASE_DIR}/bin/libssl-1_1-x64.dll

fi

echo ""
echo "Copying discord-rpc library in..."
if [ "${BUILD_BITNESS}" = "32" ] ; then
    cp -v -p $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/3rdparty/discord/rpc/lib/discord-rpc32.dll)  .
else
    cp -v -p $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/3rdparty/discord/rpc/lib/discord-rpc64.dll)  .
fi
echo ""

# Lua libraries:
echo "Copying lua C libraries in..."
cp -v -p -t . \
    ${MINGW_INTERNAL_BASE_DIR}/bin/lua51.dll \
    ${MINGW_INTERNAL_BASE_DIR}/lib/lua/5.1/lfs.dll \
    ${MINGW_INTERNAL_BASE_DIR}/lib/lua/5.1/lpeg.dll \
    ${MINGW_INTERNAL_BASE_DIR}/lib/lua/5.1/lsqlite3.dll \
    ${MINGW_INTERNAL_BASE_DIR}/lib/lua/5.1/lua-utf8.dll \
    ${MINGW_INTERNAL_BASE_DIR}/lib/lua/5.1/rex_pcre.dll \
    ${MINGW_INTERNAL_BASE_DIR}/lib/lua/5.1/yajl.dll \
    ${MINGW_INTERNAL_BASE_DIR}/lib/lua/5.1/zip.dll

mkdir ./luasql
cp -v -p ${MINGW_INTERNAL_BASE_DIR}/lib/lua/5.1/luasql/sqlite3.dll ./luasql/sqlite3.dll
echo ""

echo "Copying Mudlet & Geyser Lua files and the Generic Mapper in..."
# Using the '/./' notation provides the point at which rsync reproduces the
# directory structure from the source into the target and avoids the need
# to change directory before and after the rsync call:

# As written it copies every file but it should be polished up to skip unneeded
# ones:
rsync -avR $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER})/src/mudlet-lua/./* $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/package/mudlet-lua/)
echo ""

echo "Copying Lua code formatter Lua files in..."
# As written it copies every file but it should be polished up to skip unneeded
# ones:
rsync -avR $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER})/3rdparty/lcf/./* $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/package/lcf/)
echo ""

echo "Copying Lua translation files in..."
mkdir -p $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/package/translations/lua/translated/)
cp -v -p -t $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/package/translations/lua/translated/) \
    $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER})/translations/lua/translated/mudlet-lua_??_??.json
echo ""

echo "Copying Hunspell dictionaries in..."
cp -v -p -t . \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/de_AT_frami.aff) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/de_AT_frami.dic) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/de_CH_frami.aff) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/de_CH_frami.dic) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/de_DE_frami.aff) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/de_DE_frami.dic) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/el_GR.aff) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/el_GR.dic) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/en_GB.aff) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/en_GB.dic) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/en_US.aff) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/en_US.dic) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/es_ES.aff) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/es_ES.dic) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/fr.aff) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/fr.dic) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/it_IT.aff) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/it_IT.dic) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/nl_NL.aff) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/nl_NL.dic) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/pl_PL.aff) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/pl_PL.dic) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/pt_BR.aff) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/pt_BR.dic) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/pt_PT.aff) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/pt_PT.dic) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/ru_RU.aff) \
  $(/usr/bin/cygpath --unix ${APPVEYOR_BUILD_FOLDER}/src/ru_RU.dic)

echo ""

# For debugging purposes:
# echo "The recursive contents of the Project build sub-directory $(/usr/bin/cygpath --windows ${APPVEYOR_BUILD_FOLDER}/build/package):"
# /usr/bin/ls -aRl
# echo ""

echo "   ... appveyor.after_build.sh shell script finished!"
echo ""
