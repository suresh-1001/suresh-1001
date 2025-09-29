#!/usr/bin/env python3
import argparse, os, re, subprocess
from collections import Counter
from datetime import datetime
DEFAULT_PATTERNS=[r"\b(ERROR|CRITICAL|FAIL|FAILED|PANIC|SEGV|SEGFAULT|OOM)\b"]
def which(x): from shutil import which as w; return w(x)
def run(cmd):
  p=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
  if p.returncode not in (0,1): raise RuntimeError(p.stderr.strip())
  return p.stdout
def tail(path,n):
  try: return run(["tail","-n",str(n),path]).splitlines()
  except: return open(path,"r",errors="ignore").read().splitlines()[-n:]
def read_logs(since,grep,limit):
  if which("journalctl"):
    cmd=["journalctl","--no-pager","-n",str(limit)]
    if since: cmd+=["--since",since]
    if grep: cmd+=["-g",grep]
    return run(cmd).splitlines()
  path="/var/log/syslog"
  if not os.path.exists(path): return []
  lines=tail(path,limit)
  return [l for l in lines if (grep in l)] if grep else lines
def normalize(line):
  line=re.sub(r"\b\d{1,3}(\.\d{1,3}){3}\b","<IP>",line)
  line=re.sub(r"\[\d+\]","[]",line)
  line=re.sub(r"\d{2}:\d{2}:\d{2}","<TIME>",line)
  line=re.sub(r"\b\d+\b","<N>",line)
  return line.strip()
def main():
  ap=argparse.ArgumentParser()
  ap.add_argument("--since"); ap.add_argument("--grep"); ap.add_argument("--limit",type=int,default=10000)
  ap.add_argument("--pattern",action="append")
  a=ap.parse_args()
  pats=[re.compile(p,re.I) for p in (a.pattern or DEFAULT_PATTERNS)]
  lines=read_logs(a.since,a.grep,a.limit)
  comp_re=re.compile(r"\b([a-z0-9_.-]+)\[(\d+)\]:",re.I)
  comps, sigs, examples = Counter(), Counter(), {}
  matches=0
  for ln in lines:
    if any(p.search(ln) for p in pats):
      matches+=1; sig=normalize(ln); sigs[sig]+=1; examples.setdefault(sig,ln)
      m=comp_re.search(ln); 
      if m: comps[m.group(1)]+=1
  print("=== Log Anomaly Summary ===")
  print(f"Time: {datetime.utcnow().isoformat()}Z")
  print(f"Scanned lines: {len(lines)} | Matches: {matches}\n")
  print("Top components:"); [print(f"  {k:<20} {v}") for k,v in comps.most_common(5)]
  print("\nTop signatures:"); [print(f"  {v:>4}  {k}") for k,v in sigs.most_common(5)]
  print("\nExamples:"); [print(f"  - {v[:180]}") for k,v in list(examples.items())[:5]]
if __name__=="__main__": main()
