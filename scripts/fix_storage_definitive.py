#!/usr/bin/env python3
"""
Definitive storage.dart fix.
Shows lines 540-600, then surgically inserts methods in the right place.
"""
import os, re

STORAGE = r"C:\Users\School Work\Desktop\farmconnect_app\lib\utils\storage.dart"

with open(STORAGE, 'r', encoding='utf-8', errors='replace') as f:
    raw = f.read().replace('\r\n', '\n').replace('\r', '\n')

lines = raw.split('\n')
print(f"Total lines: {len(lines)}")
print("\nLines 545-600:")
for i, line in enumerate(lines[544:600], start=545):
    print(f"  {i:4d}: {line}")

# Find the REAL end of StorageService class
# Walk forward from class StorageService, track brace depth
ss_start_line = None
for i, line in enumerate(lines):
    if 'class StorageService {' in line:
        ss_start_line = i
        break

print(f"\nStorageService starts at line {ss_start_line+1}")

depth = 0
ss_end_line = None
for i in range(ss_start_line, len(lines)):
    depth += lines[i].count('{') - lines[i].count('}')
    if depth == 0 and i > ss_start_line:
        ss_end_line = i
        break

print(f"StorageService ends at line {ss_end_line+1}: {lines[ss_end_line]!r}")
print(f"Line after: {lines[ss_end_line+1]!r}")

# Now: remove existing broken copies of our methods from outside the class
# They appear after ss_end_line
outside_section = '\n'.join(lines[ss_end_line+1:])
outside_section = re.sub(
    r'\n?\s*//\s*── Remember password ─+\n.*?(?=\n\s*//\s*──|\nclass |\Z)',
    '', outside_section, flags=re.DOTALL
)
outside_section = re.sub(
    r'\n?\s*//\s*── Fetch counties from Supabase.*?(?=\n\s*//\s*──|\nclass |\Z)',
    '', outside_section, flags=re.DOTALL
)
outside_section = re.sub(
    r'\n  Future<void> savePassword\(.*?\n  \}', '', outside_section, flags=re.DOTALL)
outside_section = re.sub(
    r'\n  Future<bool> checkSavedPassword\(.*?\n  \}', '', outside_section, flags=re.DOTALL)
outside_section = re.sub(r'\n  String\? getSavedPhone\(\)[^\n]+', '', outside_section)
outside_section = re.sub(
    r'\n  Future<void> clearSavedPassword\(.*?\n  \}', '', outside_section, flags=re.DOTALL)
outside_section = re.sub(
    r'\n  Future<void> fetchAndCacheCounties\(.*?\n  \}', '', outside_section, flags=re.DOTALL)

# Build inside section (before the closing } of StorageService)
inside_section = '\n'.join(lines[ss_start_line:ss_end_line])  # excludes closing }

NEW_METHODS = """
  // ── Remember password ─────────────────────────────────────────
  Future<void> savePassword(String phone, String password) async {
    final p = _prefs!;
    await p.setString('saved_pass_$phone', hashPassword(password));
    await p.setString('saved_phone', phone);
  }

  Future<bool> checkSavedPassword(String phone, String password) async {
    final p = _prefs!;
    final saved = p.getString('saved_pass_$phone');
    return saved != null && saved == hashPassword(password);
  }

  String? getSavedPhone() => _prefs?.getString('saved_phone');

  Future<void> clearSavedPassword() async {
    final p = _prefs!;
    final phone = getSavedPhone();
    if (phone != null) await p.remove('saved_pass_$phone');
    await p.remove('saved_phone');
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
        await _prefs?.setString('counties_$uid', raw);
      }
    } catch (_) {}
  }
"""

# Reconstruct file
content = inside_section + NEW_METHODS + '\n}\n' + outside_section

with open(STORAGE, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print(f"\nWROTE storage.dart ({len(content):,} bytes)")

# Final verify
new_lines = content.split('\n')
print("\nNew lines around StorageService end:")
for i, line in enumerate(new_lines):
    if 'getSavedPhone' in line or 'fetchAndCacheCounties' in line or \
       'class CommunityService' in line:
        print(f"  L{i+1}: {line.strip()[:80]}")

# Check methods visible to StorageService
ss_section = content[content.find('class StorageService {'):
                     content.find('\nclass CommunityService {')]
for sig in ['savePassword', 'getSavedPhone', 'clearSavedPassword', 'fetchAndCacheCounties']:
    print(f"  {'OK' if sig in ss_section else 'MISSING'}: {sig} in StorageService")

print("\nDone. Run: flutter run -d chrome")
