#!/usr/bin/env python3
import os, sys, argparse, pathlib, re
from datetime import datetime

def read_text(p: pathlib.Path) -> str:
    if not p.exists():
        sys.exit(f"❌ File not found: {p}")
    return p.read_text(errors="ignore")

def naive_summary(log_text: str) -> str:
    errs = [l for l in log_text.splitlines() if re.search(r"\b(fail|error|crit|panic)\b", l, re.I)]
    warns = [l for l in log_text.splitlines() if re.search(r"\b(warn|degrad|oom|restart)\b", l, re.I)]
    recs = []
    if any("ssh" in l.lower() and "fail" in l.lower() for l in errs):
        recs.append("- Enforce MFA for SSH and monitor failed logins.")
    if any("disk" in l.lower() and ("space" in l.lower() or "sda" in l.lower()) for l in errs+warns):
        recs.append("- Expand/clean disk and add alerts for low space.")
    if any("nginx" in l.lower() and ("restart" in l.lower() or "failed" in l.lower()) for l in errs+warns):
        recs.append("- Review nginx error logs and configure service watchdog.")
    if not recs:
        recs.append("- Review alerts; no obvious remediation from naive scan.")

    def bullet(sample, cap):
        lines = "\n".join(f"- {l.strip()}" for l in sample[:10])
        more = f"\n- …({len(sample)-10} more)" if len(sample) > 10 else ""
        return f"### {cap}\n{lines}{more}\n" if sample else f"### {cap}\n- None observed\n"

    out = [
        "# AI Log Summary Report",
        f"_Generated: {datetime.utcnow().isoformat()}Z_",
        bullet(errs, "🔴 Critical/Errors"),
        bullet(warns, "🟠 Warnings"),
        "### 🟢 Recommendations",
        "\n".join(recs),
        ""
    ]
    return "\n".join(out)

def gpt_summary(log_text: str) -> str:
    try:
        from openai import OpenAI
        client = OpenAI()
        prompt = (
            "Summarize these logs into:\n"
            "1) 🔴 Critical/Errors (bullet list with specifics)\n"
            "2) 🟠 Warnings\n"
            "3) 🟢 Recommendations (actionable, security/compliance focus)\n\n"
            f"Logs:\n{log_text[:60_000]}"
        )
        rsp = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role":"user","content":prompt}],
            max_tokens=600,
        )
        return "# AI Log Summary Report\n\n" + rsp.choices[0].message.content.strip() + "\n"
    except Exception as e:
        return naive_summary(log_text) + f"\n> Note: GPT path failed, fell back to naive summary. ({e})\n"

def main():
    ap = argparse.ArgumentParser(description="Summarize logs into a report.")
    ap.add_argument("log_file", help="Path to log file (e.g., logs/sample_syslog.log)")
    ap.add_argument("-o","--out", default="output/summary_report.md", help="Output markdown path")
    args = ap.parse_args()

    root = pathlib.Path(__file__).resolve().parents[1]
    in_path = (root / args.log_file).resolve()
    out_path = (root / args.out).resolve()
    out_path.parent.mkdir(parents=True, exist_ok=True)

    text = read_text(in_path)
    if os.getenv("OPENAI_API_KEY"):
        summary = gpt_summary(text)
    else:
        summary = naive_summary(text)

    out_path.write_text(summary)
    print(f"✅ Summary report generated at {out_path}")

if __name__ == "__main__":
    main()
