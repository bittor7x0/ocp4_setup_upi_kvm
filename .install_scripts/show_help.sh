echo
echo "Usage: ${0} [OPTIONS]"
echo
cat << EOF | column -L -t -s '|' -N OPTION,DESCRIPTION -W DESCRIPTION
-O, --ocp-version VERSION|The OpenShift version to install.
|You can set this to "latest", "stable" or a specific version like "4.1", "4.1.2", "4.1.latest", "4.1.stable" etc.
|Default: stable
-R, --rhcos-version VERSION|You can set a specific RHCOS version to use. For example "4.1.0", "4.2.latest" etc.
|By default the RHCOS version is matched from the OpenShift version. For example, if you selected 4.1.2  RHCOS 4.1/latest will be used
-p, --pull-secret FILE|Location of the pull secret file
|Default: /root/pull-secret
-c, --cluster-name NAME|OpenShift 4 cluster name
|Default: ocp4
-d, --cluster-domain DOMAIN|OpenShift 4 cluster domain
|Default: local
-m, --masters N|Number of masters to deploy
|Default: 3
-w, --worker N|Number of workers to deploy
|Default: 2
--master-cpu N|Master VMs CPUs
|Default: 4
--master-mem SIZE(MB)|Master VMs Memory (in MB)
|Default: 16000
--worker-cpu N|Worker VMs CPUs
|Default: 4
--worker-mem SIZE(MB)|Worker VMs Memory (in MB)
|Default: 8000
--bootstrap-cpu N|Bootstrap VM CPUs
|Default: 4
--bootstrap-mem SIZE(MB)|Bootstrap VM Memory (in MB)
|Default: 16000
--lb-cpu N|Loadbalancer VM CPUs
|Default: 1
--bootstrap-mem SIZE(MB)|Loadbalancer VM Memory (in MB)
|Default: 1024
-n, --libvirt-network NETWORK|The libvirt network to use. Select this option if you want to use an existing libvirt network.
|The libvirt network should already exist. If you want the script to create a separate network for this installation see: -N, --libvirt-oct
|Default: default
-N, --libvirt-oct OCTET|You can specify a 192.168.{OCTET}.0 subnet octet and this script will create a new libvirt network for the cluster
|The network will be named ocp-{OCTET}. If the libvirt network ocp-{OCTET} already exists, it will be used.
|Default: <not set>
-v, --vm-dir|The location where you want to store the VM Disks
|Default: /var/lib/libvirt/images
-z, --dns-dir DIR|We expect the DNS on the host to be managed by dnsmasq. You can use NetworkMananger's built-in dnsmasq or use a separate dnsmasq running on the host. If you are running a separate dnsmasq on the host, set this to "/etc/dnsmasq.d"
|Default: /etc/NetworkManager/dnsmasq.d
-s, --setup-dir DIR|The location where we the script keeps all the files related to the installation
|Default: /root/ocp4_setup_{CLUSTER_NAME}
-x, --cache-dir DIR|To avoid un-necessary downloads we download the OpenShift/RHCOS files to a cache directory and reuse the files if they exist
|This way you only download a file once and reuse them for future installs
|You can force the script to download a fresh copy by using -X, --fresh-download
|Default: /root/ocp4_downloads
-X, --fresh-download|Set this if you want to force the script to download a fresh copy of the files instead of reusing the existing ones in cache dir
|Default: <not set>
-k, --keep-bootstrap|Set this if you want to keep the bootstrap VM. By default bootstrap VM is removed once the bootstraping is finished
|Default: <not set>
--autostart-vms|Set this if you want to the cluster VMs to be set to auto-start on reboot.
|Default: <not set>
-y, --yes|Set this for the script to be non-interactive and continue with out asking for confirmation
|Default: <not set>
--destroy|Set this if you want the script to destroy everything it has created.
|Use this option with the same options you used to install the cluster.
|Be carefull this deletes the VMs, DNS entries and the libvirt network (if created by the script)
|Default: <not set>
EOF
echo
echo "Examples:"
echo
echo "# Deploy OpenShift 4.3.12 cluster"
echo "${0} --ocp-version 4.3.12"
echo "${0} -O 4.3.12"
echo 
echo "# Deploy OpenShift 4.3.12 cluster with RHCOS 4.3.0"
echo "${0} --ocp-version 4.3.12 --rhcos-version 4.3.0"
echo "${0} -O 4.3.12 -R 4.3.0"
echo 
echo "# Deploy latest OpenShift version with pull secret from a custom location"
echo "${0} --pull-secret /home/knaeem/Downloads/pull-secret --ocp-version latest"
echo "${0} -p /home/knaeem/Downloads/pull-secret -O latest"
echo 
echo "# Deploy OpenShift 4.2.latest with custom cluster name and domain"
echo "${0} --cluster-name ocp43 --cluster-domain lab.test.com --ocp-version 4.2.latest"
echo "${0} -c ocp43 -d lab.test.com -O 4.2.latest"
echo
echo "# Deploy OpenShift 4.2.stable on new libvirt network (192.168.155.0/24)"
echo "${0} --ocp-version 4.2.stable --libvirt-oct 155"
echo "${0} -O 4.2.stable -N 155"
echo 
echo "# Destory the already installed cluster"
echo "${0} --cluster-name ocp43 --cluster-domain lab.test.com --destroy-installation"
echo "${0} -c ocp43 -d lab.test.com --destroy-installation"
echo
