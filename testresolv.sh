CONTAINERNAME="hotwire_wireguard_1"

CONTAINERPID=$(docker inspect --format {{.State.Pid}} $CONTAINERNAME)
sudo nsenter -n -t $CONTAINERPID ss -tulpan | grep dockerd
PORTS=$(sudo nsenter -n -t $CONTAINERPID ss -tulpan | grep dockerd | sed 's/  */ /g'| cut -d' ' -f5 | cut -d':' -f2)

echo "$PORTS" | while IFS= read -r line ; do
  echo "Testing: $line"
  sudo nsenter -n -t $CONTAINERPID dig -p $line +tcp +short google.com @127.0.0.11
  sudo nsenter -n -t $CONTAINERPID dig -p $line +short google.com @127.0.0.11
done

