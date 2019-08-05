#!/bin/bash

VAGRANT_RPMS="vagrant vagrant-libvirt"
LIBVIRT_RPMS="qemu-kvm libvirt-daemon-qemu libvirt"

err()
{
    echo "$*" 1>&2
}

err_use_devel_repo()
{
    local pkg_search="https://software.opensuse.org/package"
    local devel_repo="https://build.opensuse.org/repositories/Virtualization:vagrant"

    err
    err "Try using the development repository:"
    err "    ${devel_repo}"
    err
    err "Or search for a suitable package:"
    err "    ${pkg_search}"
    err

    return 1
}

install_vagrant()
{
    local rpm_names="$1"

    zypper -n in ${rpm_names}
    local ret="$?"
    if [ "${ret}" -eq 104 ]; then
        # 104 - ZYPPER_EXIT_INF_CAP_NOT_FOUND
        err_use_devel_repo
    fi

    return "${ret}"
}

install_libvirt()
{
    local rpm_names="$1"
    local service_name="libvirtd.service"

    zypper -n in ${rpm_names} || return "$?"

    systemctl enable "${service_name}" &&
    systemctl restart "${service_name}"
}


install_vagrant "$VAGRANT_RPMS" || exit "$?"
install_libvirt "$LIBVIRT_RPMS" || exit "$?"
