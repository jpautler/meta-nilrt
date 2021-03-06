FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

do_install_append () {
    # this logic is only for nilrt and nilrt-xfce, not for nilrt-nxg
    if ${@oe.utils.conditional('DISTRO', 'nilrt-nxg', 'false', 'true', d)}; then
        # modify sshd so that if sshd is not enabled in ni-rt.ini, sshd does not start
        sed 's|check_for_no_start() {|&\
    # if sshd is not enabled in ni-rt.ini, do not start sshd\
    enable=`/usr/local/natinst/bin/nirtcfg --get section=SystemSettings,token=sshd.enabled,value="false" \|tr "[:upper:]" "[:lower:]"`\
    if [ "$enable" != "true" ]; then\
        [ "${VERBOSE}" != "no" ] \&\& echo "SSHD not enabled in ni-rt.ini"\
        exit 0\
    fi|' -i ${D}${sysconfdir}/init.d/sshd
    fi

    # customize sshd_config
    sed -e 's|^[#[:space:]]*Banner .*|Banner /etc/issue.net|' \
        -e 's|^[#[:space:]]*UseDNS .*|UseDNS no|' \
        -e 's|^[#[:space:]]*PasswordAuthentication .*|PasswordAuthentication yes|' \
        -e 's|^[#[:space:]]*PermitEmptyPasswords .*|PermitEmptyPasswords yes|' \
        -e 's|^[#[:space:]]*PermitRootLogin .*|PermitRootLogin yes|' \
        -e 's|^[#[:space:]]*ChallengeResponseAuthentication .*|ChallengeResponseAuthentication no|' \
        -e '/.*HostKey.*/d' \
            -i ${D}${sysconfdir}/ssh/sshd_config

        echo                                                       >>${D}${sysconfdir}/ssh/sshd_config
        echo "# HostKeys for protocol version 2"                   >>${D}${sysconfdir}/ssh/sshd_config
        echo "HostKey /etc/natinst/share/ssh/ssh_host_rsa_key"     >>${D}${sysconfdir}/ssh/sshd_config
        echo "HostKey /etc/natinst/share/ssh/ssh_host_dsa_key"     >>${D}${sysconfdir}/ssh/sshd_config
        echo "HostKey /etc/natinst/share/ssh/ssh_host_ecdsa_key"   >>${D}${sysconfdir}/ssh/sshd_config
        echo "HostKey /etc/natinst/share/ssh/ssh_host_ed25519_key" >>${D}${sysconfdir}/ssh/sshd_config
}

# -transconf hook sublpackage
inherit transconf-hook
RDEPENDS_${PN}-transconf += "bash"
SRC_URI =+ "file://transconf-hooks/"
TRANSCONF_HOOKS_${PN} = "transconf-hooks/sshd"
