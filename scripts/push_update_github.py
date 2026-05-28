#!/usr/bin/env python3
"""
Use this every time you release a new version of FarmConnect.

Usage:
  python push_update_github.py VERSION GOFILE_LINK "Message"

Example:
  python push_update_github.py 1.0.2 "https://gofile.io/d/abc123" "Bug fixes and new features"

This updates version.json in your project, pushes to GitHub,
and all installed apps will see the update banner within minutes.
"""
import sys, os, json, subprocess

PROJ = r"C:\Users\School Work\Desktop\farmconnect_app"
STORAGE = os.path.join(PROJ, "lib", "utils", "storage.dart")
VERSION_JSON = os.path.join(PROJ, "version.json")

if len(sys.argv) < 3:
    print(__doc__)
    sys.exit(0)

version  = sys.argv[1]
url      = sys.argv[2]
message  = sys.argv[3] if len(sys.argv) > 3 else \
    f"FarmConnect {version} is available — tap Update to download"

# ── Step 1: Update version.json ───────────────────────────────
data = {
    "version":     version,
    "downloadUrl": url,
    "message":     message,
}
with open(VERSION_JSON, 'w', encoding='utf-8', newline='\n') as f:
    json.dump(data, f, indent=2)
print(f"  ✓ version.json updated to {version}")

# ── Step 2: Bump currentVersion in storage.dart ───────────────
with open(STORAGE, 'r', encoding='utf-8') as f:
    content = f.read()

import re
content = re.sub(
    r"static const String currentVersion = '[^']+';",
    f"static const String currentVersion = '{version}';",
    content
)
with open(STORAGE, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
print(f"  ✓ currentVersion bumped to {version} in storage.dart")

# ── Step 3: Git commit and push ───────────────────────────────
os.chdir(PROJ)
cmds = [
    ['git', 'add', 'version.json', 'lib/utils/storage.dart'],
    ['git', 'commit', '-m', f'Release v{version}'],
    ['git', 'push'],
]
for cmd in cmds:
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode == 0:
        print(f"  ✓ {' '.join(cmd[:2])}")
    else:
        print(f"  ✗ {' '.join(cmd[:2])}: {result.stderr.strip()[:80]}")

print(f"""
✅ v{version} released!

All users will see the update banner next time they open FarmConnect.

Summary:
  Version : {version}
  Link    : {url}
  Message : {message}

Remember to also share the new APK link on WhatsApp etc.
""")
