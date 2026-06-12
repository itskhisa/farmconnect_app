#!/usr/bin/env python3
"""Add missing imports to top of storage.dart"""
import os

STORAGE = r"C:\Users\School Work\Desktop\farmconnect_app\lib\utils\storage.dart"

with open(STORAGE, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read().replace('\r\n', '\n').replace('\r', '\n')

print(f"Read: {len(content):,} bytes")
print(f"First 5 lines:")
for line in content.split('\n')[:5]:
    print(f"  {line!r}")

# Required imports
REQUIRED_IMPORTS = """import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

"""

# Check which are missing
missing = []
for imp in [
    "import 'dart:convert'",
    "import 'package:http/http.dart'",
    "import 'package:shared_preferences/shared_preferences.dart'",
    "import '../models/models.dart'",
]:
    if imp not in content:
        missing.append(imp)
        print(f"  MISSING: {imp}")
    else:
        print(f"  OK: {imp}")

if missing:
    # Strip any existing partial imports to avoid duplicates
    lines = content.split('\n')
    # Remove lines that are import statements we'll re-add
    filtered = [l for l in lines if not any(
        m.replace("import '", '').replace("'", '') in l 
        for m in missing
    )]
    content = '\n'.join(filtered)
    # Prepend all required imports
    content = REQUIRED_IMPORTS + content.lstrip()
    print(f"  Added missing imports")
else:
    print("  All imports present — just verifying")

with open(STORAGE, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print(f"  WROTE storage.dart ({len(content):,} bytes)")
print("\nFirst 6 lines now:")
for line in content.split('\n')[:6]:
    print(f"  {line!r}")
print("\nRun: flutter run -d chrome")
