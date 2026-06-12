#!/usr/bin/env python3
"""Add Supabase helper functions back to storage.dart"""
import os

STORAGE = r"C:\Users\School Work\Desktop\farmconnect_app\lib\utils\storage.dart"

with open(STORAGE, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read().replace('\r\n', '\n').replace('\r', '\n')

print(f"Read: {len(content):,} bytes")

SUPABASE_HELPERS = """
// ── Supabase config ───────────────────────────────────────────
const _supabaseUrl = 'https://jiplkqrczvjliriqwjzd.supabase.co';
const _supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppcGxrcXJjenZqbGlyaXF3anpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3OTU1ODUsImV4cCI6MjA5NTM3MTU4NX0.hVPHgk209ibocWKa7Yg4a2_kB8DffwCdniTV-zyaY8Q';

Map<String, String> get _headers => {
  'apikey': _supabaseKey,
  'Authorization': 'Bearer $_supabaseKey',
  'Content-Type': 'application/json',
  'Prefer': 'return=representation',
};

Future<List<Map<String, dynamic>>> _sbSelect(String table,
    {String? filter}) async {
  final url = '$_supabaseUrl/rest/v1/$table${filter != null ? '?$filter' : ''}';
  try {
    final r = await http.get(Uri.parse(url), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (r.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(r.body) as List);
    }
  } catch (_) {}
  return [];
}

Future<bool> _sbUpsert(String table, Map<String, dynamic> data) async {
  try {
    final r = await http.post(
      Uri.parse('$_supabaseUrl/rest/v1/$table'),
      headers: {..._headers, 'Prefer': 'resolution=merge-duplicates,return=minimal'},
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 15));
    return r.statusCode >= 200 && r.statusCode < 300;
  } catch (_) { return false; }
}

Future<bool> _sbDelete(String table, String id) async {
  try {
    final r = await http.delete(
      Uri.parse('$_supabaseUrl/rest/v1/$table?id=eq.$id'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));
    return r.statusCode >= 200 && r.statusCode < 300;
  } catch (_) { return false; }
}

Future<bool> _sbUpdate(String table, String id,
    Map<String, dynamic> data) async {
  try {
    final r = await http.patch(
      Uri.parse('$_supabaseUrl/rest/v1/$table?id=eq.$id'),
      headers: _headers,
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 15));
    return r.statusCode >= 200 && r.statusCode < 300;
  } catch (_) { return false; }
}

"""

# Check if helpers are already there
if '_supabaseUrl' in content:
    print("  _supabaseUrl already present — checking if complete")
    for fn in ['_sbSelect', '_sbUpsert', '_sbDelete', '_sbUpdate']:
        print(f"  {'OK' if fn in content else 'MISSING'}: {fn}")
else:
    # Insert helpers after the imports, before class StorageService
    content = content.replace(
        "import '../models/models.dart';\n\nclass StorageService {",
        "import '../models/models.dart';\n" + SUPABASE_HELPERS + "class StorageService {"
    )
    # Also try without blank line
    content = content.replace(
        "import '../models/models.dart';\nclass StorageService {",
        "import '../models/models.dart';\n" + SUPABASE_HELPERS + "class StorageService {"
    )
    print("  Added Supabase helper functions")

with open(STORAGE, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print(f"  WROTE storage.dart ({len(content):,} bytes)")

# Verify
for check in ['_supabaseUrl', '_supabaseKey', '_sbSelect', '_sbUpsert', '_sbDelete', '_sbUpdate', '_headers']:
    print(f"  {'OK' if check in content else 'MISSING'}: {check}")

print("\nRun: flutter run -d chrome")
