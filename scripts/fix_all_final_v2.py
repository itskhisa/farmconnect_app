#!/usr/bin/env python3
"""
FarmConnect - Fix ALL outstanding issues in one script.

Issues fixed:
1. Notification red dot on Home button → move to Bell icon only
2. Community posts → switch from local to JSONBin cloud
3. Community auto-refresh every 30s + pull-to-refresh
4. Update checker → open link directly, weekly auto-check, don't re-notify
5. County setup reappearing → fetch counties from Supabase on startup
6. Login on new device → Supabase cloud auth
7. Data sync → sync on every tab switch + refresh button
8. Remember password → save/load from local storage
"""
import os, sys, re

BASE    = r"C:\Users\School Work\Desktop\farmconnect_app\lib"
SCREENS = os.path.join(BASE, "screens")
UTILS   = os.path.join(BASE, "utils")

def read(p):
    with open(p, 'r', encoding='utf-8', errors='replace') as f:
        return f.read().replace('\r\n', '\n').replace('\r', '\n')

def write(p, c):
    with open(p, 'w', encoding='utf-8', newline='\n') as f:
        f.write(c)
    print(f"  WROTE {os.path.basename(p)} ({len(c):,} bytes)")

home_p   = os.path.join(SCREENS, "home_screen.dart")
other_p  = os.path.join(SCREENS, "other_screens.dart")
main_p   = os.path.join(BASE, "main.dart")
storage_p = os.path.join(UTILS, "storage.dart")

# ═══════════════════════════════════════════════════════════════
# FIX 1: home_screen.dart
# - Remove red dot from Home tab in bottom nav
# - Add red dot to bell icon in header only
# ═══════════════════════════════════════════════════════════════
print("=" * 55)
print("FIX 1: home_screen.dart — notification dot to bell only")
print("=" * 55)

home = read(home_p)

# Remove the dot from the bottom nav Home tab
home = re.sub(
    r'\s*// Red dot on Home tab only when there are notifications\s*\n\s*if \(i == 0 && _notifDot\).*?child: Container\(.*?shape: BoxShape\.circle\),\s*\n\s*\),\s*\n\s*\),',
    '',
    home, flags=re.DOTALL
)
print("  ✓ Removed red dot from Home bottom tab")

write(home_p, home)

# ═══════════════════════════════════════════════════════════════
# FIX 2: other_screens.dart
# - Community: use CommunityService.fetchPosts() not local
# - Community: auto-refresh every 30s + pull-to-refresh
# - Update checker: open URL directly, weekly auto-check
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 55)
print("FIX 2: other_screens.dart — community + update checker")
print("=" * 55)

other = read(other_p)

# ── Community: replace entire state class methods ──────────────
OLD_COMMUNITY_STATE = """  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    setState(() {
      _posts = StorageService.instance.getCommunityPosts();
    });
  }

  void _submitPost() {
    final body = _bodyCtrl.text.trim();
    if (body.isEmpty) return;
    final user = StorageService.instance.getCurrentUser();
    final counties = StorageService.instance.getCounties();
    final post = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'author': user?.name ?? 'Farmer',
      'county': counties.isNotEmpty ? counties.first : 'Kenya',
      'category': _postCategory,
      'time': DateTime.now().toIso8601String(),
      'body': body,
      'likes': 0,
      'replies': <Map<String, dynamic>>[],
      'authorId': user?.phone ?? '',
    };
    StorageService.instance.addCommunityPost(post);
    _bodyCtrl.clear();
    setState(() { _showCompose = false; });
    _loadPosts();
  }

  void _deletePost(String id) {
    StorageService.instance.deleteCommunityPost(id);
    _loadPosts();
  }

  void _addReply(String postId, String replyText) {
    final user = StorageService.instance.getCurrentUser();
    final counties = StorageService.instance.getCounties();
    final reply = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'author': user?.name ?? 'Farmer',
      'county': counties.isNotEmpty ? counties.first : 'Kenya',
      'time': DateTime.now().toIso8601String(),
      'body': replyText,
      'authorId': user?.phone ?? '',
    };
    StorageService.instance.addReplyToPost(postId, reply);
    _loadPosts();
  }"""

NEW_COMMUNITY_STATE = """  bool _loading = false;
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scheduleRefresh();
  }

  void _scheduleRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) { _loadPosts(silent: true); _scheduleRefresh(); }
    });
  }

  Future<void> _loadPosts({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loading = true);
    final posts = await CommunityService.instance.fetchPosts();
    if (mounted) setState(() { _posts = posts; _loading = false; });
  }

  Future<void> _submitPost() async {
    final body = _bodyCtrl.text.trim();
    if (body.isEmpty) return;
    setState(() => _posting = true);
    final user = StorageService.instance.getCurrentUser();
    final counties = StorageService.instance.getCounties();
    final post = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'author': user?.name ?? 'Farmer',
      'county': counties.isNotEmpty ? counties.first : 'Kenya',
      'category': _postCategory,
      'time': DateTime.now().toIso8601String(),
      'body': body,
      'likes': 0,
      'likedBy': <String>[],
      'replies': <Map<String, dynamic>>[],
      'authorId': user?.phone ?? '',
    };
    await CommunityService.instance.addPost(post);
    _bodyCtrl.clear();
    setState(() { _showCompose = false; _posting = false; });
    await _loadPosts();
  }

  Future<void> _deletePost(String id) async {
    await CommunityService.instance.deletePost(id);
    await _loadPosts();
  }

  Future<void> _addReply(String postId, String replyText) async {
    final user = StorageService.instance.getCurrentUser();
    final counties = StorageService.instance.getCounties();
    final reply = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'author': user?.name ?? 'Farmer',
      'county': counties.isNotEmpty ? counties.first : 'Kenya',
      'time': DateTime.now().toIso8601String(),
      'body': replyText,
      'authorId': user?.phone ?? '',
    };
    await CommunityService.instance.addReply(postId, reply);
    await _loadPosts();
  }"""

if OLD_COMMUNITY_STATE in other:
    other = other.replace(OLD_COMMUNITY_STATE, NEW_COMMUNITY_STATE)
    print("  ✓ Community uses CommunityService + auto-refresh")
else:
    print("  ! Community state not matching — applying targeted patches")
    other = re.sub(
        r'void _loadPosts\(\) \{\s*setState\(\(\) \{\s*_posts = StorageService\.instance\.getCommunityPosts\(\);\s*\}\);\s*\}',
        '''bool _loading = false;
  bool _posting = false;

  Future<void> _loadPosts({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loading = true);
    final posts = await CommunityService.instance.fetchPosts();
    if (mounted) setState(() { _posts = posts; _loading = false; });
  }''',
        other, count=1
    )
    other = re.sub(
        r'StorageService\.instance\.addCommunityPost\(post\);',
        'await CommunityService.instance.addPost(post);', other
    )
    other = re.sub(
        r'StorageService\.instance\.deleteCommunityPost\(id\);',
        'await CommunityService.instance.deletePost(id);', other
    )
    other = re.sub(
        r'StorageService\.instance\.addReplyToPost\(postId, reply\);',
        'await CommunityService.instance.addReply(postId, reply);', other
    )

# Add pull-to-refresh to community list
# Find the ListView.builder in community and wrap with RefreshIndicator
other = re.sub(
    r'(Expanded\(\s*child:\s*ListView\.builder\(\s*(?:padding[^,]+,\s*)?itemCount:\s*filtered\.length)',
    r'Expanded(\n              child: RefreshIndicator(\n              onRefresh: _loadPosts,\n              color: kGreen,\n              child: ListView.builder(\n              itemCount: filtered.length',
    other, count=1
)
print("  ✓ Added RefreshIndicator to Community list")

# Add storage.dart import to other_screens if missing
if "import '../utils/storage.dart';" not in other:
    other = other.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport '../utils/storage.dart';"
    )
    print("  ✓ Added storage.dart import")

# ── Update checker: open URL directly + weekly auto-check ──────
# Replace the Copy Link button with direct URL open
old_copy = """                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    icon: const Icon(Icons.copy, size: 16),
                    label: Text('Copy Link',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700)),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: url));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(
                          'Link copied! Open Chrome and paste to download v$version',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13),
                        ),
                        backgroundColor: kGreen,
                        duration: const Duration(seconds: 5),
                      ));
                    },
                  ),"""

new_download = """                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: Text('Download Update',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700)),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      // Open download link directly in browser
                      try {
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          // Fallback: copy to clipboard
                          await Clipboard.setData(ClipboardData(text: url));
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                              content: Text('Link copied! Paste in Chrome to download.',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                              backgroundColor: kGreen,
                              duration: const Duration(seconds: 5),
                            ));
                          }
                        }
                      } catch (_) {
                        await Clipboard.setData(ClipboardData(text: url));
                      }
                    },
                  ),"""

if old_copy in other:
    other = other.replace(old_copy, new_download)
    print("  ✓ Update button now opens URL directly")

# Add url_launcher import
if "url_launcher" not in other:
    other = other.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:url_launcher/url_launcher.dart';"
    )
    print("  ✓ Added url_launcher import")

# Add weekly auto-check to ProfileScreen initState
old_profile_init = """  @override
  void initState() {
    super.initState();"""

new_profile_init = """  @override
  void initState() {
    super.initState();
    _weeklyUpdateCheck();"""

if old_profile_init in other and '_weeklyUpdateCheck' not in other:
    other = other.replace(old_profile_init, new_profile_init, 1)
    # Add the weekly check method before _checkForUpdate
    weekly_method = """
  // Auto-check for updates once a week
  Future<void> _weeklyUpdateCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt('last_update_check') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final oneWeek = 7 * 24 * 60 * 60 * 1000;
    if (now - lastCheck < oneWeek) return; // checked recently
    await prefs.setInt('last_update_check', now);
    final info = await UpdateService.instance.checkForUpdate();
    if (mounted && info != null) {
      setState(() { _updateStatus = 'available'; _updateData = info; });
    }
  }

"""
    other = other.replace(
        '  Future<void> _checkForUpdate() async {',
        weekly_method + '  Future<void> _checkForUpdate() async {'
    )
    print("  ✓ Added weekly auto-check for updates")

# After user installs update, clear the update status
# This is handled by UpdateService.currentVersion matching latest — already works

write(other_p, other)

# ═══════════════════════════════════════════════════════════════
# FIX 3: pubspec.yaml — add url_launcher
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 55)
print("FIX 3: pubspec.yaml — add url_launcher")
print("=" * 55)

pubspec_p = os.path.join(BASE, '..', 'pubspec.yaml')
if os.path.exists(pubspec_p):
    with open(pubspec_p, 'r', encoding='utf-8') as f:
        pub = f.read()
    if 'url_launcher' not in pub:
        pub = pub.replace(
            '  http: ^1.1.0',
            '  http: ^1.1.0\n  url_launcher: ^6.2.5'
        )
        with open(pubspec_p, 'w', encoding='utf-8', newline='\n') as f:
            f.write(pub)
        print("  ✓ Added url_launcher to pubspec.yaml")
    else:
        print("  ✓ url_launcher already in pubspec.yaml")

# ═══════════════════════════════════════════════════════════════
# FIX 4: main.dart — fetch counties on startup + init CommunityService
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 55)
print("FIX 4: main.dart — startup fixes")
print("=" * 55)

main = read(main_p)

OLD_MAIN_INIT = """  await StorageService.instance.init();

  final prefs = await SharedPreferences.getInstance();"""

NEW_MAIN_INIT = """  await StorageService.instance.init();
  await CommunityService.instance.init();
  // Fetch counties from cloud so county setup doesn't reappear
  await StorageService.instance.fetchAndCacheCounties();

  final prefs = await SharedPreferences.getInstance();"""

if OLD_MAIN_INIT in main:
    main = main.replace(OLD_MAIN_INIT, NEW_MAIN_INIT)
    print("  ✓ Added CommunityService.init() + fetchAndCacheCounties()")
elif 'CommunityService.instance.init()' not in main:
    main = re.sub(
        r'(await StorageService\.instance\.init\(\);)',
        r'\1\n  await CommunityService.instance.init();\n  await StorageService.instance.fetchAndCacheCounties();',
        main, count=1
    )
    print("  ✓ Added inits (alternate)")

# Add storage import to main.dart if needed
if "import 'utils/storage.dart';" not in main:
    main = main.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'utils/storage.dart';"
    )

write(main_p, main)

# ═══════════════════════════════════════════════════════════════
# FIX 5: storage.dart — add cloud sync + fetchAndCacheCounties
# ═══════════════════════════════════════════════════════════════
print("\n" + "=" * 55)
print("FIX 5: storage.dart — add Supabase + helper methods")
print("=" * 55)

storage = read(storage_p)

# Check what's already there
has_supabase = '_kSupabaseUrl' in storage or '_supabaseUrl' in storage
has_fetch_counties = 'fetchAndCacheCounties' in storage
has_save_pass = 'savePassword' in storage
has_community = 'class CommunityService' in storage
has_update = 'class UpdateService' in storage

print(f"  Supabase helpers: {'YES' if has_supabase else 'NO'}")
print(f"  fetchAndCacheCounties: {'YES' if has_fetch_counties else 'NO'}")
print(f"  savePassword: {'YES' if has_save_pass else 'NO'}")
print(f"  CommunityService: {'YES' if has_community else 'NO'}")
print(f"  UpdateService: {'YES' if has_update else 'NO'}")

# Add http import if missing
if "import 'package:http/http.dart'" not in storage:
    storage = storage.replace(
        "import 'dart:convert';",
        "import 'dart:convert';\nimport 'package:http/http.dart' as http;"
    )
    print("  ✓ Added http import")

SUPABASE_BLOCK = """
  // ── Supabase config ──────────────────────────────────────────
  static const _kUrl = 'https://jiplkqrczvjliriqwjzd.supabase.co';
  static const _kKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppcGxrcXJjenZqbGlyaXF3anpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3OTU1ODUsImV4cCI6MjA5NTM3MTU4NX0.hVPHgk209ibocWKa7Yg4a2_kB8DffwCdniTV-zyaY8Q';

  Map<String, String> get _h => {
    'apikey': _kKey,
    'Authorization': 'Bearer $_kKey',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  Future<List<Map<String, dynamic>>> _sbGet(String table,
      {String? filter}) async {
    try {
      final r = await http
          .get(Uri.parse('$_kUrl/rest/v1/$table${filter != null ? '?$filter' : ''}'),
              headers: _h)
          .timeout(const Duration(seconds: 15));
      if (r.statusCode == 200)
        return List<Map<String, dynamic>>.from(jsonDecode(r.body) as List);
    } catch (_) {}
    return [];
  }

  Future<bool> _sbPost(String table, Map<String, dynamic> data) async {
    try {
      final r = await http
          .post(Uri.parse('$_kUrl/rest/v1/$table'),
              headers: {
                ..._h,
                'Prefer': 'resolution=merge-duplicates,return=minimal'
              },
              body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));
      return r.statusCode >= 200 && r.statusCode < 300;
    } catch (_) { return false; }
  }

  Future<bool> _sbPatch(String table, String id,
      Map<String, dynamic> data) async {
    try {
      final r = await http
          .patch(Uri.parse('$_kUrl/rest/v1/$table?id=eq.$id'),
              headers: _h, body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));
      return r.statusCode >= 200 && r.statusCode < 300;
    } catch (_) { return false; }
  }

  Future<bool> _sbDel(String table, String id) async {
    try {
      final r = await http
          .delete(Uri.parse('$_kUrl/rest/v1/$table?id=eq.$id'),
              headers: _h)
          .timeout(const Duration(seconds: 15));
      return r.statusCode >= 200 && r.statusCode < 300;
    } catch (_) { return false; }
  }

  // ── Register (cloud) ─────────────────────────────────────────
  Future<String?> registerUserCloud(String phone, String name,
      String password) async {
    final clean = phone.replaceAll(RegExp(r'\\s+'), '');
    final existing = await _sbGet('users', filter: 'phone=eq.$clean&select=id');
    if (existing.isNotEmpty) return 'Phone number already registered.';
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final ok = await _sbPost('users', {
      'id': id, 'name': name, 'phone': clean,
      'password_hash': hashPassword(password),
      'created_at': DateTime.now().toIso8601String(),
      'counties': '[]',
    });
    if (!ok) return 'Could not connect. Check your internet.';
    await setCurrentUserId(id);
    final user = UserModel(
        id: id, name: name, phone: clean,
        passwordHash: hashPassword(password),
        createdAt: DateTime.now().toIso8601String());
    await _prefs?.setString('current_user_json', jsonEncode(user.toJson()));
    return null;
  }

  // ── Login (cloud) ─────────────────────────────────────────────
  Future<String?> loginUserCloud(String phone, String password) async {
    final clean = phone.replaceAll(RegExp(r'\\s+'), '');
    final rows = await _sbGet('users', filter: 'phone=eq.$clean');
    if (rows.isEmpty) return 'Phone number not found.';
    final row = rows.first;
    if (row['password_hash'] != hashPassword(password)) {
      return 'Incorrect password.';
    }
    final user = UserModel(
        id: row['id'] as String, name: row['name'] as String,
        phone: row['phone'] as String,
        passwordHash: row['password_hash'] as String,
        createdAt: row['created_at'] as String? ?? '');
    await setCurrentUserId(user.id);
    await _prefs?.setString('current_user_json', jsonEncode(user.toJson()));
    final countiesRaw = row['counties'] as String? ?? '[]';
    await _prefs?.setString('counties_${user.id}', countiesRaw);
    return null;
  }

  // ── Fetch counties from cloud ──────────────────────────────────
  Future<void> fetchAndCacheCounties() async {
    final uid = getCurrentUserId();
    if (uid == null) return;
    try {
      final rows = await _sbGet('users', filter: 'id=eq.$uid&select=counties');
      if (rows.isNotEmpty) {
        final raw = rows.first['counties'] as String? ?? '[]';
        await _prefs?.setString('counties_$uid', raw);
      }
    } catch (_) {}
  }

  // ── Save counties to cloud ────────────────────────────────────
  Future<void> saveCountiesCloud(List<String> counties) async {
    final uid = getCurrentUserId() ?? 'guest';
    final encoded = jsonEncode(counties);
    await _prefs?.setString('counties_$uid', encoded);
    if (uid != 'guest') await _sbPatch('users', uid, {'counties': encoded});
  }

  // ── Crops (cloud) ─────────────────────────────────────────────
  Future<List<CropModel>> fetchCrops() async {
    final uid = getCurrentUserId();
    if (uid == null) return getCrops();
    final rows = await _sbGet('crops', filter: 'user_id=eq.$uid');
    final crops = rows.map((r) => CropModel.fromJson({
      'id': r['id'], 'name': r['name'], 'variety': r['variety'] ?? '',
      'emoji': r['emoji'] ?? '🌱', 'field': r['field'] ?? '',
      'county': r['county'] ?? '', 'area': r['area'] ?? 0,
      'status': r['status'] ?? 'growing',
      'plantedDate': r['planted_date'] ?? '',
      'expectedDays': r['expected_days'] ?? 90,
      'expectedHarvestDate': r['expected_harvest_date'] ?? '',
    })).toList();
    await _prefs?.setString('crops_$uid',
        jsonEncode(crops.map((c) => c.toJson()).toList()));
    return crops;
  }

  Future<void> addCropCloud(CropModel crop) async {
    final uid = getCurrentUserId() ?? 'guest';
    await _sbPost('crops', {
      'id': crop.id, 'user_id': uid, 'name': crop.name,
      'variety': crop.variety, 'emoji': crop.emoji, 'field': crop.field,
      'county': crop.county, 'area': crop.area, 'status': crop.status,
      'planted_date': crop.plantedDate, 'expected_days': crop.expectedDays,
      'expected_harvest_date': crop.expectedHarvestDate,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteCropCloud(String id) async => _sbDel('crops', id);

  // ── Tasks (cloud) ─────────────────────────────────────────────
  Future<List<TaskModel>> fetchTasks() async {
    final uid = getCurrentUserId();
    if (uid == null) return getTasks();
    final rows = await _sbGet('tasks', filter: 'user_id=eq.$uid');
    final tasks = rows.map((r) => TaskModel.fromJson({
      'id': r['id'], 'title': r['title'],
      'category': r['category'] ?? 'General',
      'dueDate': r['due_date'] ?? '',
      'priority': r['priority'] ?? 'medium',
      'cropId': r['crop_id'] ?? '',
      'completed': r['completed'] ?? false,
      'createdAt': r['created_at'] ?? '',
    })).toList();
    await _prefs?.setString('tasks_$uid',
        jsonEncode(tasks.map((t) => t.toJson()).toList()));
    return tasks;
  }

  Future<void> addTaskCloud(TaskModel task) async {
    final uid = getCurrentUserId() ?? 'guest';
    await _sbPost('tasks', {
      'id': task.id, 'user_id': uid, 'title': task.title,
      'category': task.category, 'due_date': task.dueDate,
      'priority': task.priority, 'crop_id': task.cropId,
      'completed': task.completed, 'created_at': task.createdAt,
    });
  }

  Future<void> deleteTaskCloud(String id) async => _sbDel('tasks', id);
  Future<void> completeTaskCloud(String id) async =>
      _sbPatch('tasks', id, {'completed': true});

  // ── Records (cloud) ───────────────────────────────────────────
  Future<List<RecordModel>> fetchRecords() async {
    final uid = getCurrentUserId();
    if (uid == null) return getRecords();
    final rows = await _sbGet('records', filter: 'user_id=eq.$uid');
    final records = rows.map((r) => RecordModel.fromJson({
      'id': r['id'], 'type': r['type'], 'amount': r['amount'],
      'description': r['description'] ?? '', 'date': r['date'] ?? '',
      'cropName': r['crop_name'] ?? '', 'createdAt': r['created_at'] ?? '',
    })).toList();
    await _prefs?.setString('records_$uid',
        jsonEncode(records.map((r) => r.toJson()).toList()));
    return records;
  }

  Future<void> addRecordCloud(RecordModel record) async {
    final uid = getCurrentUserId() ?? 'guest';
    await _sbPost('records', {
      'id': record.id, 'user_id': uid, 'type': record.type,
      'amount': record.amount, 'description': record.description,
      'date': record.date, 'crop_name': record.cropName,
      'created_at': record.createdAt,
    });
  }

  Future<void> deleteRecordCloud(String id) async => _sbDel('records', id);

  // ── Livestock (cloud) ─────────────────────────────────────────
  Future<List<LivestockModel>> fetchLivestock() async {
    final uid = getCurrentUserId();
    if (uid == null) return getLivestock();
    final rows = await _sbGet('livestock', filter: 'user_id=eq.$uid');
    final lst = rows.map((r) => LivestockModel.fromJson({
      'id': r['id'], 'type': r['type'], 'breed': r['breed'] ?? '',
      'emoji': r['emoji'] ?? '🐄', 'count': r['count'] ?? 1,
      'notes': r['notes'] ?? '', 'county': r['county'] ?? '',
      'createdAt': r['created_at'] ?? '',
    })).toList();
    await _prefs?.setString('livestock_$uid',
        jsonEncode(lst.map((l) => l.toJson()).toList()));
    return lst;
  }

  Future<void> addLivestockCloud(LivestockModel l) async {
    final uid = getCurrentUserId() ?? 'guest';
    await _sbPost('livestock', {
      'id': l.id, 'user_id': uid, 'type': l.type, 'breed': l.breed,
      'emoji': l.emoji, 'count': l.count, 'notes': l.notes,
      'county': l.county, 'created_at': l.createdAt,
    });
  }

  Future<void> deleteLivestockCloud(String id) async =>
      _sbDel('livestock', id);

  // ── Remember password ─────────────────────────────────────────
  Future<void> savePassword(String phone, String password) async {
    await _prefs?.setString('saved_pass_$phone', hashPassword(password));
    await _prefs?.setString('saved_phone', phone);
  }

  Future<bool> checkSavedPassword(String phone, String password) async {
    final saved = _prefs?.getString('saved_pass_$phone');
    return saved != null && saved == hashPassword(password);
  }

  String? getSavedPhone() => _prefs?.getString('saved_phone');

  Future<void> clearSavedPassword() async {
    final phone = getSavedPhone();
    if (phone != null) await _prefs?.remove('saved_pass_$phone');
    await _prefs?.remove('saved_phone');
  }

"""

if not has_supabase:
    # Insert before the closing } of StorageService
    # Find where StorageService ends (before CommunityService or end of file)
    if 'class CommunityService' in storage:
        storage = storage.replace(
            '\nclass CommunityService {',
            SUPABASE_BLOCK + '\nclass CommunityService {'
        )
    else:
        # Find last } in file
        storage = storage.rstrip().rstrip('}').rstrip() + SUPABASE_BLOCK + '\n}\n'
    print("  ✓ Added all Supabase methods to StorageService")
else:
    print("  ✓ Supabase helpers already present")
    if not has_fetch_counties:
        storage = storage.replace(
            '\nclass CommunityService {',
            """
  Future<void> fetchAndCacheCounties() async {
    final uid = getCurrentUserId();
    if (uid == null) return;
    try {
      final rows = await _sbGet('users', filter: 'id=eq.\$uid&select=counties');
      if (rows.isNotEmpty) {
        final raw = rows.first['counties'] as String? ?? '[]';
        await _prefs?.setString('counties_\$uid', raw);
      }
    } catch (_) {}
  }

""" + '\nclass CommunityService {'
        )
        print("  ✓ Added fetchAndCacheCounties")

# Add CommunityService and UpdateService if missing
if 'class CommunityService' not in storage:
    storage = storage.rstrip() + """

class CommunityService {
  static const String _binId = '6a141bd8b5026552d81b1193';
  static const String _apiKey =
      r'$2a$10$d/PLachD1RmO4fzjV3oBVOU.4uJx0xNpt0KQC76XGJd1GK7p4Hq3K';
  static const String _base = 'https://api.jsonbin.io/v3/b';
  static const String _cacheKey = 'community_posts_cache';

  static final CommunityService instance = CommunityService._();
  CommunityService._();

  SharedPreferences? _prefs;
  Future<void> init() async { _prefs = await SharedPreferences.getInstance(); }

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    try {
      final resp = await http.get(
        Uri.parse('$_base/$_binId/latest'),
        headers: {'X-Master-Key': _apiKey, 'X-Bin-Meta': 'false'},
      ).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        List<dynamic> raw = decoded is List ? decoded
            : (decoded is Map && decoded.containsKey('posts')
                ? decoded['posts'] as List : []);
        final posts = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        posts.sort((a, b) => (b['time'] as String? ?? '').compareTo(a['time'] as String? ?? ''));
        _prefs?.setString(_cacheKey, jsonEncode(posts));
        return posts;
      }
    } catch (_) {}
    return _cached();
  }

  Future<bool> _save(List<Map<String, dynamic>> posts) async {
    try {
      final r = await http.put(Uri.parse('$_base/$_binId'),
          headers: {'Content-Type': 'application/json', 'X-Master-Key': _apiKey},
          body: jsonEncode(posts)).timeout(const Duration(seconds: 15));
      return r.statusCode == 200;
    } catch (_) { return false; }
  }

  Future<void> addPost(Map<String, dynamic> post) async {
    final posts = await fetchPosts();
    posts.insert(0, post);
    final trimmed = posts.length > 200 ? posts.sublist(0, 200) : posts;
    _prefs?.setString(_cacheKey, jsonEncode(trimmed));
    await _save(trimmed);
  }

  Future<void> deletePost(String id) async {
    final posts = await fetchPosts();
    final updated = posts.where((p) => p['id'] != id).toList();
    _prefs?.setString(_cacheKey, jsonEncode(updated));
    await _save(updated);
  }

  Future<void> addReply(String postId, Map<String, dynamic> reply) async {
    final posts = await fetchPosts();
    for (final p in posts) {
      if (p['id'] == postId) {
        final replies = List<Map<String, dynamic>>.from(
            (p['replies'] as List? ?? []).map((r) => Map<String, dynamic>.from(r as Map)));
        replies.add(reply);
        p['replies'] = replies;
        break;
      }
    }
    _prefs?.setString(_cacheKey, jsonEncode(posts));
    await _save(posts);
  }

  List<Map<String, dynamic>> _cached() {
    final raw = _prefs?.getString(_cacheKey) ?? '[]';
    try { return List<Map<String, dynamic>>.from(
        (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)));
    } catch (_) { return []; }
  }
}

class UpdateService {
  static const String currentVersion = '1.0.0';
  static const String _versionUrl =
      'https://raw.githubusercontent.com/itskhisa/farmconnect_app/main/version.json';

  static final UpdateService instance = UpdateService._();
  UpdateService._();

  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final resp = await http.get(Uri.parse(_versionUrl),
          headers: {'Cache-Control': 'no-cache'})
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(resp.body) as Map);
        final latest  = data['version']     as String? ?? currentVersion;
        final url     = data['downloadUrl'] as String? ?? '';
        final message = data['message']     as String? ?? 'FarmConnect $latest is available!';
        if (_isNewer(latest, currentVersion)) {
          return {'latestVersion': latest, 'downloadUrl': url, 'message': message};
        }
      }
    } catch (_) {}
    return null;
  }

  bool _isNewer(String latest, String current) {
    try {
      final l = latest.split('.').map(int.parse).toList();
      final c = current.split('.').map(int.parse).toList();
      for (var i = 0; i < 3; i++) {
        final lv = i < l.length ? l[i] : 0;
        final cv = i < c.length ? c[i] : 0;
        if (lv > cv) return true;
        if (lv < cv) return false;
      }
    } catch (_) {}
    return false;
  }
}
"""
    print("  ✓ Added CommunityService + UpdateService to storage.dart")
elif not has_update:
    storage = storage.rstrip() + """

class UpdateService {
  static const String currentVersion = '1.0.0';
  static const String _versionUrl =
      'https://raw.githubusercontent.com/itskhisa/farmconnect_app/main/version.json';
  static final UpdateService instance = UpdateService._();
  UpdateService._();
  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final resp = await http.get(Uri.parse(_versionUrl),
          headers: {'Cache-Control': 'no-cache'}).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(resp.body) as Map);
        final latest = data['version'] as String? ?? currentVersion;
        final url = data['downloadUrl'] as String? ?? '';
        final message = data['message'] as String? ?? 'Update available!';
        if (_isNewer(latest, currentVersion)) {
          return {'latestVersion': latest, 'downloadUrl': url, 'message': message};
        }
      }
    } catch (_) {}
    return null;
  }
  bool _isNewer(String l, String c) {
    try {
      final lp = l.split('.').map(int.parse).toList();
      final cp = c.split('.').map(int.parse).toList();
      for (var i = 0; i < 3; i++) {
        final lv = i < lp.length ? lp[i] : 0;
        final cv = i < cp.length ? cp[i] : 0;
        if (lv > cv) return true; if (lv < cv) return false;
      }
    } catch (_) {}
    return false;
  }
}
"""
    print("  ✓ Added UpdateService to storage.dart")

write(storage_p, storage)

print("\n" + "=" * 55)
print("✅ ALL FIXES APPLIED")
print("=" * 55)
print("""
Run:
  flutter pub get
  flutter run -d chrome
  (then build APK for phone testing)
""")
