function create_ingress_redirect_temporary() {
    for lp in {1..60};do
        if exists=$(test -f /run/docker/netns/ingress_sbox)
        then
                nsenter --net=/run/docker/netns/ingress_sbox sysctl -w net.ipv4.ip_forward=1
                exit
        else
                echo "Waiting $lp/60 - ingress_sbox does not exist"
                sleep 1
        fi
    done
}

function create_ingress_redirect_permanent() {

    if [ "$(id -u)" != "0" ]; then
        echo "This script must be run with sudo"
        exit 1
    fi    

    nsenter --net=/run/docker/netns/ingress_sbox sysctl -w net.ipv4.ip_forward=1

    echo "#!/bin/bash
    nsenter --net=/run/docker/netns/ingress_sbox sysctl -w net.ipv4.ip_forward=1" > /usr/local/bin/ipforward.sh
    chmod +x /usr/local/bin/ipforward.sh

    echo "[Unit]
Description = Set net.ipv4.ip_forward for ingress_sbox namespace
After = docker.service
Wants = docker.service

[Service]
Type = oneshot
RemainAfterExit = yes
ExecStartPre = /bin/sleep 10
ExecStart = /usr/local/bin/ipforward.sh

[Install]
WantedBy = multi-user.target" > /etc/systemd/system/ingress-sbox-ipforward.service

    systemctl daemon-reload
    systemctl enable ingress-sbox-ipforward.service

    systemctl start ingress-sbox-ipforward.service || true

    Echo "ingress-sbox-ipforward.service status:"
    systemctl status ingress-sbox-ipforward.service

}

if [ -z "$1" ]; then
    echo "Usage: $0 [-a | -b]"
    echo "  -a  create ingress redirect"
    echo "  -b  remove ingress redirect"

    exit 1
fi

if [ "$1" = "-a" ]; then
    create_ingress_redirect_temporary
elif [ "$1" = "-b" ]; then
    create_ingress_redirect_permanent
else
    echo "Error: unknown parameter $1"
    exit 1
fi
