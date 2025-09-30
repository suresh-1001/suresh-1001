import sys
import openai

openai.api_key = "YOUR_API_KEY"

def read_logs(file_path):
    with open(file_path, "r") as f:
        return f.read()

def summarize_logs(log_text):
    prompt = f"""
    Summarize the following system logs into:
    - Critical Errors
    - Warnings
    - Recommendations (security/compliance focus)

    Logs:
    {log_text}
    """
    response = openai.ChatCompletion.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=400
    )
    return response["choices"][0]["message"]["content"]

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python summarize_logs.py <log_file>")
        sys.exit(1)

    log_file = sys.argv[1]
    logs = read_logs(log_file)
    summary = summarize_logs(logs)

    with open("output/summary_report.md", "w") as f:
        f.write("# AI Log Summary Report\n\n")
        f.write(summary)

    print("✅ Summary report generated in output/summary_report.md")
