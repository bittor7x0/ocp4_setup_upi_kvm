#!/bin/bash

echo
echo "##################"
echo "#### DNS CHECK ###"
echo "##################"
echo


reload_dns(){
    systemctl $DNS_CMD $DNS_SVC || err "systemctl $DNS_CMD $DNS_SVC failed"; echo -n "."
    sleep 5
    systemctl restart libvirtd || err "systemctl restart libvirtd failed"; echo -n "."
    sleep 5
}

cleanup() {
    rm -f "/etc/hosts.dnstest" "${DNS_DIR}/dnstest.conf" &> /dev/null || \
        "Removing files /etc/hosts.dnstest, ${DNS_DIR}/dnstest.conf failed"; echo -n "."
    reload_dns
}

fail() {
    echo -n "Failed! Cleaning up: "
    cleanup
    err "$@" \
    "This means that when we created dns records using dnsmasq," \
    "they are not being picked up by the system/libvirt" \
    "See: https://github.com/kxr/ocp4_setup_upi_kvm/wiki/Setting-Up-DNS"
}


echo -n "====> Checking if first entry in /etc/resolv.conf is pointing locally: "
first_ns="$(grep -m1 "^nameserver " /etc/resolv.conf | awk '{print $2}')"
if [ "${first_ns}" == "127.0.0.1" ]; then
    ok
elif [ "${first_ns}" == "127.0.0.53" ]; then
    echo "systemd-resolved detected"
    echo -n "====> Checking if first entry in /var/run/systemd/resolve/resolv.conf is pointing locally: "
    resolved_first_ns="$(grep -m1 "^nameserver " /var/run/systemd/resolve/resolv.conf | awk '{print $2}')"
    if [ "${resolved_first_ns}" == "127.0.0.1" ]; then
        ok
    else
        err "systemd-resolved is not using local nameserver" \
        "This system is using systemd-resolved." \
        "If you have enabled a local dns server using NetworkManager or dnsmasq," \
        "You will have to tell systemd-resolved to use it." \
        "You can do this by adding the following lines in /etc/systemd/resolved.conf" \
        "" \
        "    DNS=127.0.0.1" \
        "    Domains=\"~.\"" \
        "" \
        "and restarting systemd-resolved (systemctl restart systemd-resolved)."
    fi
else
    err "First nameserver in /etc/resolv.conf is not pointing locally"
fi


echo -n "====> Creating a test host file for dnsmasq /etc/hosts.dnstest: "
echo "1.2.3.4 xxxtestxxx.${BASE_DOM}" > /etc/hosts.dnstest; ok

echo -n "====> Creating a test dnsmasq config file ${DNS_DIR}/dnstest.conf: "
cat <<EOF > "${DNS_DIR}/dnstest.conf"
local=/${CLUSTER_NAME}.${BASE_DOM}/
addn-hosts=/etc/hosts.dnstest
address=/test-wild-card.${CLUSTER_NAME}.${BASE_DOM}/5.6.7.8
EOF
ok


echo -n "====> Reloading libvirt and dnsmasq: "
reload_dns; ok

failed=""
for dns_host in ${resolved_first_ns} ${first_ns} ${LIBVIRT_GWIP} ""; do
    echo
    dig_dest=""
    test -n "${dns_host}" && dig_dest="@${dns_host}"
    
    echo -n "====> Testing forward dns via $dig_dest: "
    fwd_dig=$(dig +short "xxxtestxxx.${BASE_DOM}" ${dig_dest} 2> /dev/null)
    test "$?" -eq "0" -a "$fwd_dig" = "1.2.3.4" && ok || { failed="yes"; echo failed; }

    echo -n "====> Testing reverse dns via $dig_dest: "
    rev_dig=$(dig +short -x "1.2.3.4" ${dig_dest} 2> /dev/null)
    test "$?" -eq "0" -a "$rev_dig" = "xxxtestxxx.${BASE_DOM}." && ok || { failed="yes"; echo failed; }

    echo -n "====> Testing wildcard record via $dig_dest: "
    wc_dig=$(dig +short "blah.test-wild-card.${CLUSTER_NAME}.${BASE_DOM}" ${dig_dest} 2> /dev/null)
    test "$?" -eq "0" -a "$wc_dig" = "5.6.7.8" && ok || { failed="yes"; echo failed; }
done

echo

test -z "${failed}" || fail "One or more DNS tests failed"


echo -n "====> All DNS tests passed. Cleaning up: "
cleanup; ok
