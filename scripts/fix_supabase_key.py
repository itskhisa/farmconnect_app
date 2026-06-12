#!/usr/bin/env python3
"""Add missing _supabaseKey to storage.dart"""
import os

STORAGE = r"C:\Users\School Work\Desktop\farmconnect_app\lib\utils\storage.dart"

with open(STORAGE, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read().replace('\r\n', '\n').replace('\r', '\n')

KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppcGxrcXJjenZqbGlyaXF3anpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3OTU1ODUsImV4cCI6MjA5NTM3MTU4NX0.hVPHgk209ibocWKa7Yg4a2_kB8DffwCdniTV-zyaY8Q"

if '_supabaseKey' not in content:
    content = content.replace(
        "const _supabaseUrl = 'https://jiplkqrczvjliriqwjzd.supabase.co';",
        f"const _supabaseUrl = 'https://jiplkqrczvjliriqwjzd.supabase.co';\nconst _supabaseKey = '{KEY}';"
    )
    print("  Added _supabaseKey")
else:
    print("  _supabaseKey already present")

with open(STORAGE, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print(f"  WROTE storage.dart ({len(content):,} bytes)")
for check in ['_supabaseUrl', '_supabaseKey', '_sbSelect', '_sbUpsert', '_sbDelete', '_sbUpdate', '_headers']:
    print(f"  {'OK' if check in content else 'MISSING'}: {check}")
print("\nRun: flutter run -d chrome")
