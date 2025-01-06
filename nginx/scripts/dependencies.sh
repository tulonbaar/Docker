function create_network() {
    docker network create \
        --driver=overlay \
        --subnet=172.31.1.0/24 \
        --gateway=172.31.1.1 \
        --ip-range=172.31.1.0/24 \
        nginx_network
}

function remove_network() {
    docker network rm nginx_network
}

if [ -z "$1" ]; then
    echo "Usage: $0 [-a | -b]"
    echo "  -a  create Docker network"
    echo "  -b  remove Docker network"

    exit 1
fi


if [ "$1" = "-a" ]; then
    create_network
elif [ "$1" = "-b" ]; then
    remove_network
else
    echo "Error: unknown parameter $1"
    exit 1
fi



