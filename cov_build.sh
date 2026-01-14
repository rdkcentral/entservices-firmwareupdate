#!/bin/bash
set -e
set -x
##############################
GITHUB_WORKSPACE="${PWD}"
ls -la ${GITHUB_WORKSPACE}
############################
# Build entservices-firmwareupdate
echo "======================================================================================"
echo "building entservices-firmwareupdate"

cd ${GITHUB_WORKSPACE}
cmake -G Ninja -S "$GITHUB_WORKSPACE" -B build/entservices-firmwareupdate \
-DUSE_THUNDER_R4=ON \
-DCMAKE_INSTALL_PREFIX="$GITHUB_WORKSPACE/install/usr" \
-DCMAKE_MODULE_PATH="$GITHUB_WORKSPACE/install/tools/cmake" \
-DCMAKE_VERBOSE_MAKEFILE=ON \
-DCMAKE_DISABLE_FIND_PACKAGE_IARMBus=ON \
-DCMAKE_DISABLE_FIND_PACKAGE_RFC=ON \
-DLIBOPKG_LIBRARIES="" \
-DLIBOPKG_INCLUDE_DIRS="" \
-DCOMCAST_CONFIG=OFF \
-DRDK_SERVICES_COVERITY=ON \
-DRDK_SERVICES_L1_TEST=ON \
-DPLUGIN_FIRMWAREUPDATE=ON \
-DCMAKE_CXX_FLAGS="-DEXCEPTIONS_ENABLE=ON \
-I ${GITHUB_WORKSPACE}/entservices-testframework/Tests/headers \
-I ${GITHUB_WORKSPACE}/entservices-testframework/Tests/headers/rdk/iarmbus \
-I ${GITHUB_WORKSPACE}/entservices-testframework/Tests/headers/rdk/iarmmgrs-hal \
-I ${GITHUB_WORKSPACE}/entservices-testframework/Tests/mocks \
-I ${GITHUB_WORKSPACE}/entservices-testframework/Tests/mocks/thunder \
-I /usr/include/libdrm \
-include ${GITHUB_WORKSPACE}/entservices-testframework/Tests/mocks/Iarm.h \
-include ${GITHUB_WORKSPACE}/entservices-testframework/Tests/mocks/Rfc.h \
-include ${GITHUB_WORKSPACE}/entservices-testframework/Tests/mocks/Telemetry.h \
-include ${GITHUB_WORKSPACE}/entservices-testframework/Tests/mocks/Udev.h \
-include ${GITHUB_WORKSPACE}/entservices-testframework/Tests/mocks/pkg.h \
-include ${GITHUB_WORKSPACE}/entservices-testframework/Tests/mocks/maintenanceMGR.h \
-include ${GITHUB_WORKSPACE}/entservices-testframework/Tests/mocks/wpa_ctrl_mock.h \
-include ${GITHUB_WORKSPACE}/entservices-testframework/Tests/mocks/secure_wrappermock.h \
-Wall -Wno-unused-result -Wno-deprecated-declarations -Werror -Wno-error=format -Wl,-wrap,system -Wl,-wrap,popen -Wl,-wrap,syslog -Wl,-wrap,wpa_ctrl_open -Wl,-wrap,wpa_ctrl_request -Wl,-wrap,wpa_ctrl_close -Wl,-wrap,wpa_ctrl_pending -Wl,-wrap,wpa_ctrl_recv -Wl,-wrap,wpa_ctrl_attach -DENABLE_TELEMETRY_LOGGING -DUSE_IARMBUS -DENABLE_SET_WAKEUP_SRC_CONFIG -DHAS_API_SYSTEM -DDISABLE_SECURITY_TOKEN -DUSE_THUNDER_R4=ON -DTHUNDER_VERSION=4 -DTHUNDER_VERSION_MAJOR=4 -DTHUNDER_VERSION_MINOR=4"

cmake --build build/entservices-firmwareupdate --target install
echo "======================================================================================"
exit 0
