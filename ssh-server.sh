 
#!/bin/bash

if [[ -z "$NGROK_TOKEN" ]]; then
  echo "Please set 'NGROK_TOKEN'"
  exit 2
fi

if [[ -z "$SSH_PASSWORD" ]]; then
  echo "Please set 'SSH_PASSWORD' for user: $USER"
  exit 3
fi

wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar -xvzf ngrok-v3-stable-linux-amd64.tgz
chmod +x ./ngrok

echo -e "$SSH_PASSWORD\n$SSH_PASSWORD" | sudo passwd "$USER"

rm -f .ngrok.log
./ngrok authtoken "$NGROK_TOKEN"
./ngrok tcp 22 --log ".ngrok.log" &

sleep 10

HAS_ERRORS=$(grep "command failed" < .ngrok.log)

if [[ -z "$HAS_ERRORS" ]]; then
  echo ""
  echo "To connect: $(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")"
  echo ""
else
  echo "$HAS_ERRORS"
  exit 4
fi

