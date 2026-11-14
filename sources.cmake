# Source files for the KisakBlack target.
#
# Game code (src/ and tl/) is globbed: every .cpp in those trees is compiled.
# Vendored code (third_party/) is selected per library, because some of it is
# deliberately not built (alternate implementations, tests, tools).

set(GLOB_FLAGS CONFIGURE_DEPENDS)

# ----- Game code -----
file(GLOB_RECURSE GAME_SOURCES ${GLOB_FLAGS}
    "${SRC_DIR}/*.cpp" "${SRC_DIR}/*.h"
    "${TL_DIR}/*.cpp"  "${TL_DIR}/*.h"
)

# ----- Vendored code -----
# One directory, .c/.cpp/.h only. Add the extra argument "RECURSE" to include subdirectories.
function(add_vendored_dir out dir)
    if ("RECURSE" IN_LIST ARGN)
        set(glob GLOB_RECURSE)
    else()
        set(glob GLOB)
    endif()
    file(${glob} files ${GLOB_FLAGS} "${dir}/*.c" "${dir}/*.cpp" "${dir}/*.h")
    set(${out} ${files} PARENT_SCOPE)
endfunction()

add_vendored_dir(V_CUBEMAPGEN "${THIRD_PARTY_DIR}/CubeMapGenLib")
add_vendored_dir(V_BINKLIB    "${THIRD_PARTY_DIR}/binklib")
add_vendored_dir(V_ZLIB       "${THIRD_PARTY_DIR}/zlib")
add_vendored_dir(V_MINILZO    "${THIRD_PARTY_DIR}/minilzo")
add_vendored_dir(V_SPEEX      "${THIRD_PARTY_DIR}/speex")
add_vendored_dir(V_LIBSPEEX   "${THIRD_PARTY_DIR}/speex/libspeex")
add_vendored_dir(V_STEAM      "${THIRD_PARTY_DIR}/steam")
add_vendored_dir(V_NVAPI      "${THIRD_PARTY_DIR}/nvapi")
add_vendored_dir(V_JPEG       "${THIRD_PARTY_DIR}/jpeg")
add_vendored_dir(V_LIBTOMMATH "${THIRD_PARTY_DIR}/libs/libtommath-1.0")
add_vendored_dir(V_LIBTOMCRYPT "${THIRD_PARTY_DIR}/libs/libtomcrypt-1.17/src" RECURSE)

# Files in those directories that are not part of the build.
list(FILTER V_JPEG EXCLUDE REGEX "/jmem(name|nobs)\\.c$")           # other memory managers; jmemansi.c is used
list(FILTER V_LIBTOMCRYPT EXCLUDE REGEX "/hashes/md4\\.c$|/modes/lrw/")  # unused algorithms

# Tracy: only the client is built (and only when TRACY_ENABLE is defined, see CMakeLists.txt).
set(V_TRACY
    "${THIRD_PARTY_DIR}/tracy/public/TracyClient.cpp"
    "${THIRD_PARTY_DIR}/tracy/public/tracy/Tracy.hpp"
    "${THIRD_PARTY_DIR}/tracy/public/tracy/TracyC.h"
)

set(VENDORED_SOURCES
    ${V_CUBEMAPGEN} ${V_BINKLIB} ${V_ZLIB} ${V_MINILZO} ${V_SPEEX} ${V_LIBSPEEX}
    ${V_STEAM} ${V_NVAPI} ${V_JPEG} ${V_LIBTOMMATH} ${V_LIBTOMCRYPT} ${V_TRACY}
)

add_executable(${BIN_NAME} ${GAME_SOURCES} ${VENDORED_SOURCES})

# Visual Studio folders mirror the directory layout.
source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES ${GAME_SOURCES} ${VENDORED_SOURCES})
