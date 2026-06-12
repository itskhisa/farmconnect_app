#!/usr/bin/env python3
"""Remove _weeklyUpdateCheck from WeatherScreen and ensure it's in ProfileScreen"""
import os, re

OTHER = r"C:\Users\School Work\Desktop\farmconnect_app\lib\screens\other_screens.dart"

with open(OTHER, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read().replace('\r\n', '\n').replace('\r', '\n')

print(f"Read: {len(content):,} bytes")

# Find all initState occurrences and which class they belong to
lines = content.split('\n')
for i, line in enumerate(lines):
    if '_weeklyUpdateCheck' in line:
        # Find which class this is in by searching backward
        for j in range(i, max(0, i-50), -1):
            if 'class _' in lines[j] and 'State' in lines[j]:
                print(f"  Found _weeklyUpdateCheck at L{i+1} in: {lines[j].strip()}")
                break

# Remove from WeatherScreen initState specifically
# Pattern: in _WeatherScreenState initState
content = re.sub(
    r'(class _WeatherScreenState.*?void initState\(\) \{.*?super\.initState\(\);.*?)\n\s*_weeklyUpdateCheck\(\);',
    r'\1',
    content, flags=re.DOTALL, count=1
)

# Also remove the _weeklyUpdateCheck method if it ended up in WeatherScreen
content = re.sub(
    r'(class _WeatherScreenState.*?)(\n  // Auto-check for updates once a week\n  Future<void> _weeklyUpdateCheck\(\) async \{.*?\n  \}\n)',
    r'\1',
    content, flags=re.DOTALL, count=1
)

# Now ensure it IS in ProfileScreen initState
profile_init = re.search(
    r'(class _ProfileScreenState.*?void initState\(\) \{[^\}]*super\.initState\(\);)',
    content, re.DOTALL
)
if profile_init:
    section = content[profile_init.start():profile_init.end()+200]
    if '_weeklyUpdateCheck' not in section:
        content = content.replace(
            profile_init.group(0),
            profile_init.group(0) + '\n    _weeklyUpdateCheck();'
        )
        print("  ✓ Added _weeklyUpdateCheck to ProfileScreen initState")
    else:
        print("  ✓ _weeklyUpdateCheck already in ProfileScreen")

# Verify
lines = content.split('\n')
for i, line in enumerate(lines):
    if '_weeklyUpdateCheck' in line:
        for j in range(i, max(0, i-60), -1):
            if 'class _' in lines[j] and 'State' in lines[j]:
                print(f"  After fix — L{i+1} in: {lines[j].strip()}")
                break

with open(OTHER, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
print(f"  WROTE other_screens.dart ({len(content):,} bytes)")
print("\nRun: flutter run -d chrome")
