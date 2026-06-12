#!/usr/bin/env python3
"""Add _weeklyUpdateCheck method definition to _ProfileScreenState"""
import os, re

OTHER = r"C:\Users\School Work\Desktop\farmconnect_app\lib\screens\other_screens.dart"

with open(OTHER, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read().replace('\r\n', '\n').replace('\r', '\n')

print(f"Read: {len(content):,} bytes")

# Confirm it's missing from ProfileScreen
profile_start = content.find('class _ProfileScreenState')
profile_end = content.find('\nclass ', profile_start + 1)
profile_section = content[profile_start:profile_end]

if '_weeklyUpdateCheck' in profile_section and 'Future<void> _weeklyUpdateCheck' in profile_section:
    print("  Method already defined in ProfileScreen")
else:
    print("  Method missing — inserting before _checkForUpdate")
    
    WEEKLY_METHOD = '''
  // Auto-check for updates once a week silently
  Future<void> _weeklyUpdateCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt('last_update_check') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      const oneWeek = 7 * 24 * 60 * 60 * 1000;
      if (now - lastCheck < oneWeek) return;
      await prefs.setInt('last_update_check', now);
      final info = await UpdateService.instance.checkForUpdate();
      if (mounted && info != null) {
        setState(() { _updateStatus = 'available'; _updateData = info; });
      }
    } catch (_) {}
  }

'''

    # Insert before _checkForUpdate in ProfileScreen section
    # Find _checkForUpdate within profile section
    check_method = '  Future<void> _checkForUpdate() async {'
    if check_method in profile_section:
        insert_pos = content.find(check_method, profile_start)
        content = content[:insert_pos] + WEEKLY_METHOD + content[insert_pos:]
        print("  ✓ Inserted _weeklyUpdateCheck before _checkForUpdate")
    else:
        # Insert before _updateMenuItem
        update_menu = '  Widget _updateMenuItem('
        if update_menu in profile_section:
            insert_pos = content.find(update_menu, profile_start)
            content = content[:insert_pos] + WEEKLY_METHOD + content[insert_pos:]
            print("  ✓ Inserted _weeklyUpdateCheck before _updateMenuItem")
        else:
            print("  ERROR: Could not find insertion point")

# Also add SharedPreferences import if missing
if "import 'package:shared_preferences/shared_preferences.dart';" not in content:
    content = content.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:shared_preferences/shared_preferences.dart';"
    )
    print("  ✓ Added SharedPreferences import")

with open(OTHER, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
print(f"  WROTE other_screens.dart ({len(content):,} bytes)")
print("\nRun: flutter run -d chrome")
