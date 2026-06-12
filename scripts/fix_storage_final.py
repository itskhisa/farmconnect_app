#!/usr/bin/env python3
"""
Final fix for storage.dart - read exact file, find StorageService class,
insert methods properly inside it.
"""
import os, re

STORAGE = r"C:\Users\School Work\Desktop\farmconnect_app\lib\utils\storage.dart"

with open(STORAGE, 'r', encoding='utf-8', errors='replace') as f:
    raw = f.read().replace('\r\n', '\n').replace('\r', '\n')

print(f"Read: {len(raw):,} bytes")

# ── Step 1: Remove ALL existing copies of these methods everywhere ──
methods_to_remove = [
    r'  // ── Remember password.*?  \}\n\n',
    r'  // ── Fetch counties from Supabase on startup.*?  \}\n\n',
    r'  Future<void> savePassword\(String phone, String password\) async \{.*?  \}\n',
    r'  Future<bool> checkSavedPassword\(String phone, String password\) async \{.*?  \}\n',
    r'  String\? getSavedPhone\(\) => [^\n]+\n',
    r'  Future<void> clearSavedPassword\(\) async \{.*?  \}\n',
    r'  Future<void> fetchAndCacheCounties\(\) async \{.*?  \}\n',
]
for pattern in methods_to_remove:
    raw = re.sub(pattern, '', raw, flags=re.DOTALL)

print("  Removed all existing copies of methods")

# ── Step 2: Find StorageService class boundaries precisely ──────
# Find start of StorageService
ss_start = raw.find('class StorageService {')
# Find start of CommunityService (end of StorageService)
cs_start = raw.find('\nclass CommunityService {')

if ss_start == -1 or cs_start == -1:
    print(f"ERROR: ss_start={ss_start}, cs_start={cs_start}")
    exit(1)

print(f"  StorageService: chars {ss_start} to {cs_start}")

# Everything before CommunityService
before_cs = raw[:cs_start].rstrip()
after_cs  = raw[cs_start:]

# The StorageService section should end with exactly one }
# Count braces in the StorageService section
opens  = before_cs[ss_start:].count('{')
closes = before_cs[ss_start:].count('}')
print(f"  StorageService braces: {opens} open, {closes} close")

# Remove any trailing closing braces beyond what's needed
# We need exactly opens == closes
while before_cs.endswith('}') and closes > opens:
    before_cs = before_cs[:-1].rstrip()
    closes -= 1

# ── Step 3: Add the methods inside StorageService ───────────────
METHODS_INSIDE = """

  // ── Remember password ─────────────────────────────────────────
  Future<void> savePassword(String phone, String password) async {
    await prefs.setString('saved_pass_$phone', hashPassword(password));
    await prefs.setString('saved_phone', phone);
  }

  Future<bool> checkSavedPassword(String phone, String password) async {
    final saved = prefs.getString('saved_pass_$phone');
    return saved != null && saved == hashPassword(password);
  }

  String? getSavedPhone() => prefs.getString('saved_phone');

  Future<void> clearSavedPassword() async {
    final phone = getSavedPhone();
    if (phone != null) await prefs.remove('saved_pass_$phone');
    await prefs.remove('saved_phone');
  }

  // ── Fetch counties from Supabase on startup ────────────────────
  Future<void> fetchAndCacheCounties() async {
    final uid = getCurrentUserId();
    if (uid == null) return;
    try {
      final rows = await _sbSelect('users',
          filter: 'id=eq.$uid&select=counties');
      if (rows.isNotEmpty) {
        final raw = rows.first['counties'] as String? ?? '[]';
        await prefs.setString('counties_$uid', raw);
      }
    } catch (_) {}
  }
}"""

# Combine: StorageService (without closing brace) + methods + rest
content = before_cs + METHODS_INSIDE + '\n' + after_cs

with open(STORAGE, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print(f"  WROTE storage.dart ({len(content):,} bytes)")

# ── Verify ──────────────────────────────────────────────────────
# Check all methods appear exactly once and are inside StorageService
ss_section = content[content.find('class StorageService {'):
                     content.find('\nclass CommunityService {')]

checks = {
    'savePassword': 'Future<void> savePassword(',
    'getSavedPhone': 'String? getSavedPhone()',
    'clearSavedPassword': 'Future<void> clearSavedPassword()',
    'fetchAndCacheCounties': 'Future<void> fetchAndCacheCounties()',
}
all_ok = True
for name, sig in checks.items():
    in_ss   = sig in ss_section
    count   = content.count(sig)
    status  = 'OK' if (in_ss and count == 1) else 'FAIL'
    if status == 'FAIL': all_ok = False
    print(f"  {status}: {name} — in StorageService: {in_ss}, count: {count}")

# Check CommunityService and UpdateService still there
for cls in ['class CommunityService {', 'class UpdateService {']:
    found = cls in content
    print(f"  {'OK' if found else 'MISSING'}: {cls}")
    if not found: all_ok = False

print(f"\n  {'✅ All good — run flutter' if all_ok else '❌ Issues remain'}")
