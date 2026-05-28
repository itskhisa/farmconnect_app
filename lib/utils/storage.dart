import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

// ── Supabase config ───────────────────────────────────────────────
const _supabaseUrl = 'https://jiplkqrczvjliriqwjzd.supabase.co';
const _supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppcGxrcXJjenZqbGlyaXF3anpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3OTU1ODUsImV4cCI6MjA5NTM3MTU4NX0.hVPHgk209ibocWKa7Yg4a2_kB8DffwCdniTV-zyaY8Q';

Map<String, String> get _headers => {
  'apikey': _supabaseKey,
  'Authorization': 'Bearer $_supabaseKey',
  'Content-Type': 'application/json',
  'Prefer': 'return=representation',
};

// Generic Supabase REST helpers
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

// ═════════════════════════════════════════════════════════════════
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) throw Exception('StorageService not initialised.');
    return _prefs!;
  }

  // ── Password hashing ──────────────────────────────────────────
  static String hashPassword(String s) {
    int h = 5381;
    for (final c in s.codeUnits) { h = ((h << 5) + h) + c; }
    return h.abs().toRadixString(16);
  }

  // ── Current user session (local only) ─────────────────────────
  Future<void> setCurrentUserId(String id) =>
      prefs.setString('current_user_id', id);
  String? getCurrentUserId() => prefs.getString('current_user_id');
  Future<void> logout() => prefs.remove('current_user_id');

  UserModel? getCurrentUser() {
    final raw = prefs.getString('current_user_json');
    if (raw == null) return null;
    try { return UserModel.fromJson(jsonDecode(raw)); } catch (_) { return null; }
  }

  Future<void> _cacheCurrentUser(UserModel u) =>
      prefs.setString('current_user_json', jsonEncode(u.toJson()));

  // ── Register ──────────────────────────────────────────────────
  Future<String?> registerUser(String phone, String name,
      String password) async {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');

    // Check if phone already exists in Supabase
    final existing = await _sbSelect('users',
        filter: 'phone=eq.$clean&select=id');
    if (existing.isNotEmpty) return 'Phone number already registered.';

    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: clean,
      passwordHash: hashPassword(password),
      createdAt: DateTime.now().toIso8601String(),
    );

    final ok = await _sbUpsert('users', {
      'id': user.id,
      'name': user.name,
      'phone': user.phone,
      'password_hash': user.passwordHash,
      'created_at': user.createdAt,
      'counties': '[]',
    });

    if (!ok) return 'Could not connect to server. Check your internet.';
    await setCurrentUserId(user.id);
    await _cacheCurrentUser(user);
    return null;
  }

  // ── Login ─────────────────────────────────────────────────────
  Future<String?> loginUser(String phone, String password) async {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');

    final rows = await _sbSelect('users', filter: 'phone=eq.$clean');
    if (rows.isEmpty) return 'Phone number not found.';

    final row = rows.first;
    if (row['password_hash'] != hashPassword(password)) {
      return 'Incorrect password.';
    }

    final user = UserModel(
      id: row['id'] as String,
      name: row['name'] as String,
      phone: row['phone'] as String,
      passwordHash: row['password_hash'] as String,
      createdAt: row['created_at'] as String? ?? '',
    );

    await setCurrentUserId(user.id);
    await _cacheCurrentUser(user);

    // Cache counties locally
    final countiesRaw = row['counties'] as String? ?? '[]';
    await prefs.setString('counties_${user.id}', countiesRaw);

    return null;
  }

  // ── Change password ───────────────────────────────────────────
  Future<String?> changeUserPassword(String oldPass, String newPass) async {
    final user = getCurrentUser();
    if (user == null) return 'Not logged in.';
    if (user.passwordHash != hashPassword(oldPass)) {
      return 'Current password is incorrect.';
    }
    final newHash = hashPassword(newPass);
    await _sbUpdate('users', user.id, {'password_hash': newHash});
    user.passwordHash = newHash;
    await _cacheCurrentUser(user);
    return null;
  }

  // ── Account deletion ──────────────────────────────────────────
  Future<void> requestAccountDeletion() async {
    final user = getCurrentUser();
    if (user == null) return;
    await _sbDelete('users', user.id);
    await logout();
    await prefs.remove('current_user_json');
  }

  void runGracePeriodCleanup() {} // handled by Supabase cascade delete

  // ── Remember phone ────────────────────────────────────────────
  Future<void> setRememberPhone(String? phone) async {
    if (phone != null) {
      await prefs.setString('remembered_phone', phone);
    } else {
      await prefs.remove('remembered_phone');
    }
  }
  String? getRememberedPhone() => prefs.getString('remembered_phone');

  // ── Counties ──────────────────────────────────────────────────
  Future<void> saveCounties(List<String> counties) async {
    final uid = getCurrentUserId();
    if (uid == null) return;
    final encoded = jsonEncode(counties);
    await prefs.setString('counties_$uid', encoded);
    await _sbUpdate('users', uid, {'counties': encoded});
  }

  List<String> getCounties() {
    final uid = getCurrentUserId() ?? 'guest';
    final raw = prefs.getString('counties_$uid');
    if (raw == null) return [];
    return List<String>.from(jsonDecode(raw));
  }

  // ── Crops ──────────────────────────────────────────────────────
  Future<List<CropModel>> fetchCrops() async {
    final uid = getCurrentUserId();
    if (uid == null) return _getCachedCrops();
    final rows = await _sbSelect('crops', filter: 'user_id=eq.$uid');
    if (rows.isEmpty && await _sbSelect('users',
        filter: 'id=eq.$uid&select=id').then((r) => r.isEmpty)) {
      return _getCachedCrops();
    }
    final crops = rows.map((r) => CropModel.fromJson({
      'id': r['id'], 'name': r['name'], 'variety': r['variety'] ?? '',
      'emoji': r['emoji'] ?? '🌱', 'field': r['field'] ?? '',
      'county': r['county'] ?? '', 'area': r['area'] ?? 0,
      'status': r['status'] ?? 'growing',
      'plantedDate': r['planted_date'] ?? '',
      'expectedDays': r['expected_days'] ?? 90,
      'expectedHarvestDate': r['expected_harvest_date'] ?? '',
    })).toList();
    // Cache locally
    await prefs.setString('crops_$uid',
        jsonEncode(crops.map((c) => c.toJson()).toList()));
    return crops;
  }

  List<CropModel> getCrops() => _getCachedCrops();

  List<CropModel> _getCachedCrops() {
    final uid = getCurrentUserId() ?? 'guest';
    final raw = prefs.getString('crops_$uid');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((j) => CropModel.fromJson(j)).toList();
  }

  Future<void> addCrop(CropModel crop) async {
    final uid = getCurrentUserId() ?? 'guest';
    // Update local cache immediately
    final crops = _getCachedCrops()..add(crop);
    await prefs.setString('crops_$uid',
        jsonEncode(crops.map((c) => c.toJson()).toList()));
    // Sync to cloud
    await _sbUpsert('crops', {
      'id': crop.id, 'user_id': uid, 'name': crop.name,
      'variety': crop.variety, 'emoji': crop.emoji, 'field': crop.field,
      'county': crop.county, 'area': crop.area, 'status': crop.status,
      'planted_date': crop.plantedDate, 'expected_days': crop.expectedDays,
      'expected_harvest_date': crop.expectedHarvestDate,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateCrop(CropModel updated) async {
    final uid = getCurrentUserId() ?? 'guest';
    final crops = _getCachedCrops()
        .map((c) => c.id == updated.id ? updated : c).toList();
    await prefs.setString('crops_$uid',
        jsonEncode(crops.map((c) => c.toJson()).toList()));
    await _sbUpdate('crops', updated.id, {
      'name': updated.name, 'variety': updated.variety,
      'status': updated.status, 'area': updated.area,
    });
  }

  Future<void> deleteCrop(String id) async {
    final uid = getCurrentUserId() ?? 'guest';
    final crops = _getCachedCrops().where((c) => c.id != id).toList();
    await prefs.setString('crops_$uid',
        jsonEncode(crops.map((c) => c.toJson()).toList()));
    await _sbDelete('crops', id);
    // Cascade tasks
    final tasks = _getCachedTasks().where((t) => t.cropId != id).toList();
    await prefs.setString('tasks_$uid',
        jsonEncode(tasks.map((t) => t.toJson()).toList()));
    await http.delete(
      Uri.parse('$_supabaseUrl/rest/v1/tasks?user_id=eq.$uid&crop_id=eq.$id'),
      headers: _headers,
    ).timeout(const Duration(seconds: 10));
  }

  Future<void> saveCrops(List<CropModel> crops) async {
    final uid = getCurrentUserId() ?? 'guest';
    await prefs.setString('crops_$uid',
        jsonEncode(crops.map((c) => c.toJson()).toList()));
  }

  // ── Tasks ──────────────────────────────────────────────────────
  Future<List<TaskModel>> fetchTasks() async {
    final uid = getCurrentUserId();
    if (uid == null) return _getCachedTasks();
    final rows = await _sbSelect('tasks', filter: 'user_id=eq.$uid');
    final tasks = rows.map((r) => TaskModel.fromJson({
      'id': r['id'], 'title': r['title'],
      'category': r['category'] ?? 'General',
      'dueDate': r['due_date'] ?? '',
      'priority': r['priority'] ?? 'medium',
      'cropId': r['crop_id'] ?? '',
      'completed': r['completed'] ?? false,
      'createdAt': r['created_at'] ?? '',
    })).toList();
    await prefs.setString('tasks_$uid',
        jsonEncode(tasks.map((t) => t.toJson()).toList()));
    return tasks;
  }

  List<TaskModel> getTasks() => _getCachedTasks();

  List<TaskModel> _getCachedTasks() {
    final uid = getCurrentUserId() ?? 'guest';
    final raw = prefs.getString('tasks_$uid');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((j) => TaskModel.fromJson(j)).toList();
  }

  Future<void> addTask(TaskModel task) async {
    final uid = getCurrentUserId() ?? 'guest';
    final tasks = _getCachedTasks()..add(task);
    await prefs.setString('tasks_$uid',
        jsonEncode(tasks.map((t) => t.toJson()).toList()));
    await _sbUpsert('tasks', {
      'id': task.id, 'user_id': uid, 'title': task.title,
      'category': task.category, 'due_date': task.dueDate,
      'priority': task.priority, 'crop_id': task.cropId,
      'completed': task.completed,
      'created_at': task.createdAt,
    });
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    final uid = getCurrentUserId() ?? 'guest';
    await prefs.setString('tasks_$uid',
        jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  Future<void> completeTask(String id) async {
    final uid = getCurrentUserId() ?? 'guest';
    final tasks = _getCachedTasks().map((t) {
      if (t.id == id) t.completed = true;
      return t;
    }).toList();
    await prefs.setString('tasks_$uid',
        jsonEncode(tasks.map((t) => t.toJson()).toList()));
    await _sbUpdate('tasks', id, {'completed': true});
  }

  Future<void> deleteTask(String id) async {
    final uid = getCurrentUserId() ?? 'guest';
    final tasks = _getCachedTasks().where((t) => t.id != id).toList();
    await prefs.setString('tasks_$uid',
        jsonEncode(tasks.map((t) => t.toJson()).toList()));
    await _sbDelete('tasks', id);
  }

  // ── Records ────────────────────────────────────────────────────
  Future<List<RecordModel>> fetchRecords() async {
    final uid = getCurrentUserId();
    if (uid == null) return _getCachedRecords();
    final rows = await _sbSelect('records', filter: 'user_id=eq.$uid');
    final records = rows.map((r) => RecordModel.fromJson({
      'id': r['id'], 'type': r['type'],
      'amount': r['amount'], 'description': r['description'] ?? '',
      'date': r['date'] ?? '', 'cropName': r['crop_name'] ?? '',
      'createdAt': r['created_at'] ?? '',
    })).toList();
    await prefs.setString('records_$uid',
        jsonEncode(records.map((r) => r.toJson()).toList()));
    return records;
  }

  List<RecordModel> getRecords() => _getCachedRecords();

  List<RecordModel> _getCachedRecords() {
    final uid = getCurrentUserId() ?? 'guest';
    final raw = prefs.getString('records_$uid');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((j) => RecordModel.fromJson(j)).toList();
  }

  Future<void> addRecord(RecordModel record) async {
    final uid = getCurrentUserId() ?? 'guest';
    final records = _getCachedRecords()..add(record);
    await prefs.setString('records_$uid',
        jsonEncode(records.map((r) => r.toJson()).toList()));
    await _sbUpsert('records', {
      'id': record.id, 'user_id': uid, 'type': record.type,
      'amount': record.amount, 'description': record.description,
      'date': record.date, 'crop_name': record.cropName,
      'created_at': record.createdAt,
    });
  }

  Future<void> saveRecords(List<RecordModel> records) async {
    final uid = getCurrentUserId() ?? 'guest';
    await prefs.setString('records_$uid',
        jsonEncode(records.map((r) => r.toJson()).toList()));
  }

  Future<void> deleteRecord(String id) async {
    final uid = getCurrentUserId() ?? 'guest';
    final records = _getCachedRecords().where((r) => r.id != id).toList();
    await prefs.setString('records_$uid',
        jsonEncode(records.map((r) => r.toJson()).toList()));
    await _sbDelete('records', id);
  }

  // ── Livestock ──────────────────────────────────────────────────
  Future<List<LivestockModel>> fetchLivestock() async {
    final uid = getCurrentUserId();
    if (uid == null) return _getCachedLivestock();
    final rows = await _sbSelect('livestock', filter: 'user_id=eq.$uid');
    final lst = rows.map((r) => LivestockModel.fromJson({
      'id': r['id'], 'type': r['type'], 'breed': r['breed'] ?? '',
      'emoji': r['emoji'] ?? '🐄', 'count': r['count'] ?? 1,
      'notes': r['notes'] ?? '', 'county': r['county'] ?? '',
      'createdAt': r['created_at'] ?? '',
    })).toList();
    await prefs.setString('livestock_$uid',
        jsonEncode(lst.map((l) => l.toJson()).toList()));
    return lst;
  }

  List<LivestockModel> getLivestock() => _getCachedLivestock();

  List<LivestockModel> _getCachedLivestock() {
    final uid = getCurrentUserId() ?? 'guest';
    final raw = prefs.getString('livestock_$uid');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((j) => LivestockModel.fromJson(j)).toList();
  }

  Future<void> addLivestock(LivestockModel l) async {
    final uid = getCurrentUserId() ?? 'guest';
    final lst = _getCachedLivestock()..add(l);
    await prefs.setString('livestock_$uid',
        jsonEncode(lst.map((x) => x.toJson()).toList()));
    await _sbUpsert('livestock', {
      'id': l.id, 'user_id': uid, 'type': l.type, 'breed': l.breed,
      'emoji': l.emoji, 'count': l.count, 'notes': l.notes,
      'county': l.county, 'created_at': l.createdAt,
    });
  }

  Future<void> saveLivestock(List<LivestockModel> lst) async {
    final uid = getCurrentUserId() ?? 'guest';
    await prefs.setString('livestock_$uid',
        jsonEncode(lst.map((l) => l.toJson()).toList()));
  }

  Future<void> deleteLivestock(String id) async {
    final uid = getCurrentUserId() ?? 'guest';
    final lst = _getCachedLivestock().where((l) => l.id != id).toList();
    await prefs.setString('livestock_$uid',
        jsonEncode(lst.map((l) => l.toJson()).toList()));
    await _sbDelete('livestock', id);
    // Cascade: remove vaccination records
    final vaccRecords = getVaccinationRecords()
        .where((r) => r['livestockId']?.toString() != id).toList();
    await _prefs?.setString('vaccination_records', jsonEncode(vaccRecords));
    // Cascade: remove linked tasks
    final tasks = _getCachedTasks()
        .where((t) => t.cropId != id).toList();
    await prefs.setString('tasks_$uid',
        jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  // ── Vaccination Records (local only for now) ───────────────────
  List<Map<String, dynamic>> getVaccinationRecords() {
    final raw = _prefs?.getString('vaccination_records') ?? '[]';
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) { return []; }
  }

  Future<void> addVaccinationRecord(Map<String, dynamic> record) async {
    final records = getVaccinationRecords()..add(record);
    await _prefs?.setString('vaccination_records', jsonEncode(records));
    if (record['nextDueDate'] != null &&
        record['nextDueDate'].toString().isNotEmpty) {
      await addTask(TaskModel(
        id: 'vacc_${record['id']}',
        title: 'Vaccinate ${record['animalType']} — ${record['vaccineName']}',
        category: 'Vaccination',
        dueDate: record['nextDueDate'].toString(),
        priority: 'high',
        cropId: record['livestockId'].toString(),
        createdAt: DateTime.now().toIso8601String(),
        completed: false,
      ));
    }
  }

  Future<void> deleteVaccinationRecord(String id) async {
    final records = getVaccinationRecords()
        .where((r) => r['id'] != id).toList();
    await _prefs?.setString('vaccination_records', jsonEncode(records));
    await deleteTask('vacc_$id');
  }

  // ── Community (handled by CommunityService) ────────────────────
  List<Map<String, dynamic>> getCommunityPosts() {
    final raw = _prefs?.getString('community_posts') ?? '[]';
    try {
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) { return []; }
  }

  Future<void> addCommunityPost(Map<String, dynamic> post) async {
    final posts = getCommunityPosts()..insert(0, post);
    await _prefs?.setString('community_posts',
        jsonEncode(posts.take(100).toList()));
  }

  Future<void> deleteCommunityPost(String id) async {
    final posts = getCommunityPosts().where((p) => p['id'] != id).toList();
    await _prefs?.setString('community_posts', jsonEncode(posts));
  }

  Future<void> addReplyToPost(String postId,
      Map<String, dynamic> reply) async {
    final posts = getCommunityPosts();
    final idx = posts.indexWhere((p) => p['id'] == postId);
    if (idx >= 0) {
      final post = Map<String, dynamic>.from(posts[idx]);
      final replies = List<Map<String, dynamic>>.from(
          (post['replies'] as List?)
              ?.map((r) => Map<String, dynamic>.from(r as Map))
              .toList() ?? []);
      replies.add(reply);
      post['replies'] = replies;
      posts[idx] = post;
      await _prefs?.setString('community_posts', jsonEncode(posts));
    }
  }
}

// ════════════════════════════════════════════════════════════
// UpdateService — checks GitHub for new app versions


class CommunityService {
  static const String _binId  = '6a141bd8b5026552d81b1193';
  static const String _apiKey = '\$2a\$10\$d/PLachD1RmO4fzjV3oBVOU.4uJx0xNpt0KQC76XGJd1GK7p4Hq3K';
  static const String _base   = 'https://api.jsonbin.io/v3/b';
  static const String _cacheKey = 'community_posts_cache';

  static final CommunityService instance = CommunityService._();
  CommunityService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Map<String, dynamic>>> fetchPosts() async {
    try {
      final resp = await http.get(
        Uri.parse('\$_base/\$_binId/latest'),
        headers: {'X-Master-Key': _apiKey, 'X-Bin-Meta': 'false'},
      ).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        List<dynamic> raw = decoded is List
            ? decoded
            : (decoded is Map && decoded.containsKey('posts')
                ? decoded['posts'] as List
                : []);
        final posts = raw
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        posts.sort((a, b) =>
            (b['time'] as String? ?? '').compareTo(a['time'] as String? ?? ''));
        _prefs?.setString(_cacheKey, jsonEncode(posts));
        return posts;
      }
    } catch (_) {}
    return _getCachedPosts();
  }

  Future<bool> _savePosts(List<Map<String, dynamic>> posts) async {
    try {
      final resp = await http.put(
        Uri.parse('\$_base/\$_binId'),
        headers: {'Content-Type': 'application/json', 'X-Master-Key': _apiKey},
        body: jsonEncode(posts),
      ).timeout(const Duration(seconds: 15));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> addPost(Map<String, dynamic> post) async {
    final posts = await fetchPosts();
    posts.insert(0, post);
    final trimmed = posts.length > 200 ? posts.sublist(0, 200) : posts;
    _prefs?.setString(_cacheKey, jsonEncode(trimmed));
    await _savePosts(trimmed);
  }

  Future<void> deletePost(String id) async {
    final posts = await fetchPosts();
    final updated = posts.where((p) => p['id'] != id).toList();
    _prefs?.setString(_cacheKey, jsonEncode(updated));
    await _savePosts(updated);
  }

  Future<void> addReply(String postId, Map<String, dynamic> reply) async {
    final posts = await fetchPosts();
    for (final p in posts) {
      if (p['id'] == postId) {
        final replies = List<Map<String, dynamic>>.from(
            (p['replies'] as List? ?? [])
                .map((r) => Map<String, dynamic>.from(r as Map)));
        replies.add(reply);
        p['replies'] = replies;
        break;
      }
    }
    _prefs?.setString(_cacheKey, jsonEncode(posts));
    await _savePosts(posts);
  }

  Future<void> toggleLike(String postId, String userId) async {
    final posts = await fetchPosts();
    for (final p in posts) {
      if (p['id'] == postId) {
        final likedBy = List<String>.from(
            (p['likedBy'] as List? ?? []).map((e) => e.toString()));
        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
        } else {
          likedBy.add(userId);
        }
        p['likedBy'] = likedBy;
        p['likes']   = likedBy.length;
        break;
      }
    }
    _prefs?.setString(_cacheKey, jsonEncode(posts));
    await _savePosts(posts);
  }

  List<Map<String, dynamic>> _getCachedPosts() {
    final raw = _prefs?.getString(_cacheKey) ?? '[]';
    try {
      return List<Map<String, dynamic>>.from(
          (jsonDecode(raw) as List)
              .map((e) => Map<String, dynamic>.from(e as Map)));
    } catch (_) {
      return [];
    }
  }

}

class UpdateService {
  static const String currentVersion = '1.0.4';
  static const String _versionUrl =
      'https://raw.githubusercontent.com/itskhisa/farmconnect_app/main/version.json';

  static final UpdateService instance = UpdateService._();
  UpdateService._();

  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final resp = await http.get(
        Uri.parse(_versionUrl),
        headers: {'Cache-Control': 'no-cache'},
      ).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(resp.body) as Map);
        final latest  = data['version']     as String? ?? currentVersion;
        final url     = data['downloadUrl'] as String? ?? '';
        final message = data['message']     as String? ?? 'FarmConnect \$latest is available!';
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
