#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2018 ANSSI. All rights reserved.

# Safety settings: do not remove!
set -o errexit -o nounset -o pipefail

# The prelude to every script for this SDK. Do not remove it.
source /mnt/products/${CURRENT_SDK_PRODUCT}/${CURRENT_SDK_RECIPE}/scripts/prelude.sh

readonly nginx_config="/mnt/products/${CURRENT_PRODUCT}/${CURRENT_RECIPE}/configure.d/config/"
readonly factory="/usr/share/factory"

# Empty /etc/tmpfiles.d/nginx.conf
echo -n "" > "${CURRENT_OUT_ROOT}/etc/tmpfiles.d/nginx.conf"


einfo "Install custom nginx config in factory"
install -o 0 -g 0 -m 0750 -d "${CURRENT_OUT_ROOT}/${factory}/nginx"
install -o 0 -g 0 -m 640 \
    "${nginx_config}/nginx.conf" \
    "${CURRENT_OUT_ROOT}/${factory}/nginx/nginx.conf"

cat >> "${CURRENT_OUT_ROOT}/etc/tmpfiles.d/nginx.conf" << EOF
d /mnt/state/core/etc/nginx 0750 root nginx
C /mnt/state/core/etc/nginx/nginx.conf 0640 root nginx - ${factory}/nginx/nginx.conf
EOF

# Remove default nginx config & setup symbolic link
rm "${CURRENT_OUT_ROOT}/etc/nginx/nginx.conf"
ln -s "/mnt/state/core/etc/nginx/nginx.conf" "${CURRENT_OUT_ROOT}/etc/nginx/nginx.conf"


einfo "Setup tmpfiles.d config for nginx state folders"
cat >> "${CURRENT_OUT_ROOT}/etc/tmpfiles.d/nginx.conf" << EOF
d /var/lib/nginx     0750 root  nginx
d /var/lib/nginx/www 0750 root  nginx
d /var/lib/nginx/tmp 0750 nginx nginx
EOF


einfo "Install custom nginx service unit"
rm "${CURRENT_OUT_ROOT}/lib/systemd/system/nginx.service"
install -o 0 -g 0 -m 0644 "${nginx_config}/nginx.service" \
    "${CURRENT_OUT_ROOT}/etc/systemd/system/nginx.service"

cat >> "${CURRENT_OUT_ROOT}/etc/tmpfiles.d/nginx.conf" << EOF
d /run/nginx         0750 nginx nginx
EOF

einfo "Enable nginx by default"
systemctl --root="${CURRENT_OUT_ROOT}" enable nginx

# vim: set ts=4 sts=4 sw=4 et ft=sh:
