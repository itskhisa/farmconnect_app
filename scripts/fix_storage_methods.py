#!/usr/bin/env python3
"""Fix methods that were inserted outside StorageService class"""
import os, re

STORAGE = r"C:\Users\School Work\Desktop\farmconnect_app\lib\utils\storage.dart"

with open(STORAGE, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read().replace('\r\n', '\n').replace('\r', '\n')

print(f"Read storage.dart ({len(content):,} bytes)")

# Find where StorageService class ends and CommunityService begins
comm_pos = content.find('\nclass CommunityService {')
storage_section = content[:comm_pos]
rest = content[comm_pos:]

# Remove any methods that got inserted outside StorageService
# (between the last } of StorageService and class CommunityService)
# These are the savePassword, checkSavedPassword, getSavedPhone,
# clearSavedPassword, fetchAndCacheCounties methods

# Strip them from outside the class
rest_cleaned = re.sub(
    r'\n\s*//\s*──[^\n]*remember password[^\n]*\n.*?(?=\nclass )',
    '\n',
    rest, flags=re.DOTALL | re.IGNORECASE
)
rest_cleaned = re.sub(
    r'\n\s*//\s*──[^\n]*Fetch counties[^\n]*\n.*?(?=\nclass )',
    '\n',
    rest_cleaned, flags=re.DOTALL | re.IGNORECASE
)

# Also remove standalone method definitions outside any class
rest_cleaned = re.sub(
    r'\n  Future<void> savePassword\(.*?\n  \}\n',
    '\n', rest_cleaned, flags=re.DOTALL
)
rest_cleaned = re.sub(
    r'\n  Future<bool> checkSavedPassword\(.*?\n  \}\n',
    '\n', rest_cleaned, flags=re.DOTALL
)
rest_cleaned = re.sub(
    r'\n  String\? getSavedPhone\(\).*?\n',
    '\n', rest_cleaned
)
rest_cleaned = re.sub(
    r'\n  Future<void> clearSavedPassword\(.*?\n  \}\n',
    '\n', rest_cleaned, flags=re.DOTALL
)
rest_cleaned = re.sub(
    r'\n  Future<void> fetchAndCacheCounties\(.*?\n  \}\n',
    '\n', rest_cleaned, flags=re.DOTALL
)

# Now insert them INSIDE StorageService, before its closing brace
# Find the last } before CommunityService
storage_trimmed = storage_section.rstrip()
# Remove trailing } to open StorageService back up
if storage_trimmed.endswith('}'):
    storage_trimmed = storage_trimmed[:-1].rstrip()

NEW_METHODS = """
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

}
"""

content = storage_trimmed + NEW_METHODS + rest_cleaned

with open(STORAGE, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print(f"  WROTE storage.dart ({len(content):,} bytes)")

# Verify
checks = [
    'Future<void> savePassword',
    'String? getSavedPhone',
    'Future<void> clearSavedPassword',
    'Future<void> fetchAndCacheCounties',
    'class CommunityService {',
    'class UpdateService {',
]
for c in checks:
    found = c in content
    print(f"  {'OK' if found else 'MISSING'}: {c}")

print("\n  Run: flutter run -d chrome")
