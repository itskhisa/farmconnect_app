import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Restore any backup data if main users key is missing
    _restoreFromBackup();
  }

  void _restoreFromBackup() {
    final hasUsers = _prefs!.containsKey('users');
    final hasBackup = _prefs!.containsKey('users_backup');
    if (!hasUsers && hasBackup) {
      _prefs!.setString('users', _prefs!.getString('users_backup')!);
    }
  }

  SharedPreferences get prefs {
    if (_prefs == null) throw Exception('StorageService not initialised. Call init() first.');
    return _prefs!;
  }

  // ── Auth ────────────────────────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    final users = getAllUsers();
    users.removeWhere((u) => u.phone == user.phone);
    users.add(user);
    final encoded = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString('users', encoded);
    await prefs.setString('users_backup', encoded); // redundant backup
  }

  List<UserModel> getAllUsers() {
    final raw = prefs.getString('users');
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((j) => UserModel.fromJson(j)).toList();
  }

  UserModel? findUser(String phone) {
    try {
      return getAllUsers().firstWhere((u) => u.phone == phone);
    } catch (_) { return null; }
  }

  Future<void> setCurrentUserId(String id) =>
      prefs.setString('current_user_id', id);

  String? getCurrentUserId() => prefs.getString('current_user_id');

  UserModel? getCurrentUser() {
    final id = getCurrentUserId();
    if (id == null) return null;
    try {
      return getAllUsers().firstWhere((u) => u.id == id);
    } catch (_) { return null; }
  }

  Future<void> logout() => prefs.remove('current_user_id');

  // ── Auth helpers ────────────────────────────────────────────────
  static String hashPassword(String s) {
    int h = 5381;
    for (final c in s.codeUnits) { h = ((h << 5) + h) + c; }
    return h.abs().toRadixString(16);
  }

  static const _graceDays = 3;

  Future<String?> registerUser(String phone, String name, String password) async {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');
    if (findUser(clean) != null) return 'Phone number already registered.';
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name, phone: clean,
      passwordHash: hashPassword(password),
      createdAt: DateTime.now().toIso8601String(),
    );
    await saveUser(user);
    return null;
  }

  Future<String?> loginUser(String phone, String password) async {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');
    final user = findUser(clean);

    // Check grace period recovery
    final deletedAtStr = prefs.getString('deleted_at_$clean');
    if (deletedAtStr != null) {
      final deletedAt = DateTime.tryParse(deletedAtStr);
      if (deletedAt != null) {
        final elapsed = DateTime.now().difference(deletedAt).inDays;
        if (elapsed < _graceDays) {
          if (user != null && user.passwordHash == hashPassword(password)) {
            await prefs.remove('deleted_at_$clean');
            await setCurrentUserId(user.id);
            return null; // restored
          }
          return 'Incorrect password.';
        } else {
          // Grace period over - permanently delete
          final users = getAllUsers()..removeWhere((u) => u.phone == clean);
          await prefs.setString('users', jsonEncode(users.map((u) => u.toJson()).toList()));
          await prefs.remove('deleted_at_$clean');
          return 'This account has been permanently deleted.';
        }
      }
    }

    if (user == null) return 'Phone number not found.';
    if (user.passwordHash != hashPassword(password)) return 'Incorrect password.';
    await setCurrentUserId(user.id);
    return null;
  }

  Future<void> setRememberPhone(String? phone) async {
    if (phone != null) {
      await prefs.setString('remembered_phone', phone);
    } else {
      await prefs.remove('remembered_phone');
    }
  }

  String? getRememberedPhone() => prefs.getString('remembered_phone');

  Future<String?> changeUserPassword(String oldPassword, String newPassword) async {
    final user = getCurrentUser();
    if (user == null) return 'Not logged in.';
    if (user.passwordHash != hashPassword(oldPassword)) return 'Current password is incorrect.';
    user.passwordHash = hashPassword(newPassword);
    await saveUser(user);
    return null;
  }

  Future<void> requestAccountDeletion() async {
    final user = getCurrentUser();
    if (user == null) return;
    await prefs.setString('deleted_at_${user.phone}', DateTime.now().toIso8601String());
    await logout();
  }

  void runGracePeriodCleanup() {
    final keys = prefs.getKeys().where((k) => k.startsWith('deleted_at_')).toList();
    for (final key in keys) {
      final phone = key.substring('deleted_at_'.length);
      final deletedAt = DateTime.tryParse(prefs.getString(key) ?? '');
      if (deletedAt != null &&
          DateTime.now().difference(deletedAt).inDays >= _graceDays) {
        final users = getAllUsers()..removeWhere((u) => u.phone == phone);
        prefs.setString('users', jsonEncode(users.map((u) => u.toJson()).toList()));
        prefs.remove(key);
      }
    }
  }

  // ── Crops ───────────────────────────────────────────────────

  String get _cropKey => 'crops_${getCurrentUserId() ?? "guest"}';

  Future<void> saveCrops(List<CropModel> crops) async =>
      prefs.setString(_cropKey, jsonEncode(crops.map((c) => c.toJson()).toList()));

  List<CropModel> getCrops() {
    final raw = prefs.getString(_cropKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((j) => CropModel.fromJson(j)).toList();
  }

  Future<void> addCrop(CropModel crop) async {
    final crops = getCrops()..add(crop);
    await saveCrops(crops);
  }

  Future<void> updateCrop(CropModel updated) async {
    final crops = getCrops().map((c) => c.id == updated.id ? updated : c).toList();
    await saveCrops(crops);
  }

  Future<void> deleteCrop(String id) async {
    final crop = getCrops().firstWhere((c) => c.id == id,
        orElse: () => getCrops().first);
    // Cascade: delete all tasks linked to this crop
    final tasks = getTasks().where((t) => t.cropId != id).toList();
    await saveTasks(tasks);
    // Remove the crop
    await saveCrops(getCrops().where((c) => c.id != id).toList());
  }

  // ── Tasks ───────────────────────────────────────────────────

  String get _taskKey => 'tasks_${getCurrentUserId() ?? "guest"}';

  Future<void> saveTasks(List<TaskModel> tasks) async =>
      prefs.setString(_taskKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));

  List<TaskModel> getTasks() {
    final raw = prefs.getString(_taskKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((j) => TaskModel.fromJson(j)).toList();
  }

  Future<void> addTask(TaskModel task) async {
    final tasks = getTasks()..add(task);
    await saveTasks(tasks);
  }

  Future<void> completeTask(String id) async {
    final tasks = getTasks().map((t) {
      if (t.id == id) t.completed = true;
      return t;
    }).toList();
    await saveTasks(tasks);
  }

  Future<void> deleteTask(String id) async =>
      saveTasks(getTasks().where((t) => t.id != id).toList());

  // ── Records ─────────────────────────────────────────────────

  String get _recordKey => 'records_${getCurrentUserId() ?? "guest"}';

  Future<void> saveRecords(List<RecordModel> records) async =>
      prefs.setString(_recordKey, jsonEncode(records.map((r) => r.toJson()).toList()));

  List<RecordModel> getRecords() {
    final raw = prefs.getString(_recordKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((j) => RecordModel.fromJson(j)).toList();
  }

  Future<void> addRecord(RecordModel record) async {
    final records = getRecords()..add(record);
    await saveRecords(records);
  }

  Future<void> deleteRecord(String id) async =>
      saveRecords(getRecords().where((r) => r.id != id).toList());

  // ── Livestock ────────────────────────────────────────────────

  String get _livestockKey => 'livestock_${getCurrentUserId() ?? "guest"}';

  Future<void> saveLivestock(List<LivestockModel> lst) async =>
      prefs.setString(_livestockKey, jsonEncode(lst.map((l) => l.toJson()).toList()));

  List<LivestockModel> getLivestock() {
    final raw = prefs.getString(_livestockKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((j) => LivestockModel.fromJson(j)).toList();
  }

  Future<void> addLivestock(LivestockModel l) async {
    await saveLivestock(getLivestock()..add(l));
  }

  Future<void> deleteLivestock(String id) async {
    // Cascade: delete all vaccination records for this animal
    final vaccRecords = getVaccinationRecords()
        .where((r) => r['livestockId']?.toString() != id).toList();
    await _prefs?.setString('vaccination_records', json.encode(vaccRecords));
    // Cascade: delete all vaccination reminder tasks (cropId stores the livestock id)
    final tasks = getTasks()
        .where((t) => t.cropId != id).toList();
    await saveTasks(tasks);
    // Delete the livestock entry itself
    await saveLivestock(getLivestock().where((l) => l.id != id).toList());
  }

  // ── Counties ─────────────────────────────────────────────────

  Future<void> saveCounties(List<String> counties) async =>
      prefs.setString('counties_${getCurrentUserId() ?? "guest"}',
          jsonEncode(counties));

  List<String> getCounties() {
    final raw = prefs.getString('counties_${getCurrentUserId() ?? "guest"}');
    if (raw == null) return [];
    return List<String>.from(jsonDecode(raw));
  }

  // ── Community Posts ──────────────────────────────────────────
  List<Map<String, dynamic>> getCommunityPosts() {
    final raw = _prefs?.getString('community_posts') ?? '[]';
    try {
      final list = json.decode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) { return []; }
  }

  Future<void> addCommunityPost(Map<String, dynamic> post) async {
    final posts = getCommunityPosts();
    posts.insert(0, post);
    // Keep max 100 user posts
    final trimmed = posts.take(100).toList();
    await _prefs?.setString('community_posts', json.encode(trimmed));
  }

  // ── Vaccination Records ───────────────────────────────────────
  List<Map<String, dynamic>> getVaccinationRecords() {
    final raw = _prefs?.getString('vaccination_records') ?? '[]';
    try {
      final list = json.decode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) { return []; }
  }

  Future<void> addVaccinationRecord(Map<String, dynamic> record) async {
    final records = getVaccinationRecords();
    records.add(record);
    await _prefs?.setString('vaccination_records', json.encode(records));
    // Auto-create a task reminder for the next vaccination
    if (record['nextDueDate'] != null && record['nextDueDate'].toString().isNotEmpty) {
      await addTask(TaskModel(
        id: 'vacc_' + record['id'].toString(),
        title: 'Vaccinate ' + record['animalType'].toString() + ' — ' + record['vaccineName'].toString(),
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
    final records = getVaccinationRecords().where((r) => r['id'] != id).toList();
    await _prefs?.setString('vaccination_records', json.encode(records));
    // Also remove the linked task
    final tasks = getTasks().where((t) => t.id != 'vacc_' + id).toList();
    await saveTasks(tasks);
  }

  Future<void> deleteCommunityPost(String id) async {
    final posts = getCommunityPosts().where((p) => p['id'] != id).toList();
    await _prefs?.setString('community_posts', json.encode(posts));
  }

  Future<void> addReplyToPost(String postId, Map<String, dynamic> reply) async {
    final posts = getCommunityPosts();
    final idx = posts.indexWhere((p) => p['id'] == postId);
    if (idx >= 0) {
      final post = Map<String, dynamic>.from(posts[idx]);
      final replies = List<Map<String, dynamic>>.from(
          (post['replies'] as List?)?.map((r) => Map<String, dynamic>.from(r as Map)).toList() ?? []);
      replies.add(reply);
      post['replies'] = replies;
      posts[idx] = post;
      await _prefs?.setString('community_posts', json.encode(posts));
    }
  }
}


// ═══════════════════════════════════════════════════════════════
// CommunityService — shared posts across all phones via JSONBin.io
// ═══════════════════════════════════════════════════════════════
class CommunityService {
  static const String _binId  = '6a141bd8b5026552d81b1193';   // ← replaced by setup script
  static const String _apiKey = '/PLachD1RmO4fzjV3oBVOU.4uJx0xNpt0KQC76XGJd1GK7p4Hq3K';  // ← replaced by setup script
  static const String _base   = 'https://api.jsonbin.io/v3/b';
  static const String _cacheKey = 'community_posts_cache';

  static final CommunityService instance = CommunityService._();
  CommunityService._();

  SharedPreferences? _prefs;
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Fetch posts from cloud (returns cached if offline) ────────
  Future<List<Map<String, dynamic>>> fetchPosts() async {
    try {
      final resp = await http.get(
        Uri.parse('$_base/$_binId/latest'),
        headers: {
          'X-Master-Key': _apiKey,
          'X-Bin-Meta': 'false',
        },
      ).timeout(const Duration(seconds: 15));

      if (resp.statusCode == 200) {
        final decoded = json.decode(resp.body);
        List<dynamic> raw = [];
        if (decoded is List) {
          raw = decoded;
        } else if (decoded is Map && decoded.containsKey('posts')) {
          raw = decoded['posts'] as List;
        }
        final posts = raw
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        // Sort newest first
        posts.sort((a, b) =>
            (b['time'] as String? ?? '').compareTo(a['time'] as String? ?? ''));
        // Cache locally for offline use
        _prefs?.setString(_cacheKey, json.encode(posts));
        return posts;
      }
    } catch (_) {}
    // Offline fallback
    return _getCachedPosts();
  }

  // ── Save full posts list to cloud ─────────────────────────────
  Future<bool> _savePosts(List<Map<String, dynamic>> posts) async {
    try {
      final resp = await http.put(
        Uri.parse('$_base/$_binId'),
        headers: {
          'Content-Type': 'application/json',
          'X-Master-Key': _apiKey,
        },
        body: json.encode(posts),
      ).timeout(const Duration(seconds: 15));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Add a new post ────────────────────────────────────────────
  Future<void> addPost(Map<String, dynamic> post) async {
    final posts = await fetchPosts();
    posts.insert(0, post);
    // Keep last 200 posts
    final trimmed = posts.length > 200 ? posts.sublist(0, 200) : posts;
    _prefs?.setString(_cacheKey, json.encode(trimmed));
    await _savePosts(trimmed);
  }

  // ── Delete a post ─────────────────────────────────────────────
  Future<void> deletePost(String id) async {
    final posts = await fetchPosts();
    final updated = posts.where((p) => p['id'] != id).toList();
    _prefs?.setString(_cacheKey, json.encode(updated));
    await _savePosts(updated);
  }

  // ── Add a reply ───────────────────────────────────────────────
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
    _prefs?.setString(_cacheKey, json.encode(posts));
    await _savePosts(posts);
  }

  // ── Toggle like ───────────────────────────────────────────────
  Future<void> toggleLike(String postId, String userId) async {
    final posts = await fetchPosts();
    for (final p in posts) {
      if (p['id'] == postId) {
        final likedBy = List<String>.from((p['likedBy'] as List? ?? []).map((e) => e.toString()));
        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
        } else {
          likedBy.add(userId);
        }
        p['likedBy'] = likedBy;
        p['likes'] = likedBy.length;
        break;
      }
    }
    _prefs?.setString(_cacheKey, json.encode(posts));
    await _savePosts(posts);
  }

  // ── Local cache fallback ──────────────────────────────────────
  List<Map<String, dynamic>> _getCachedPosts() {
    final raw = _prefs?.getString(_cacheKey) ?? '[]';
    try {
      return List<Map<String, dynamic>>.from(
          (json.decode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)));
    } catch (_) { return []; }
  }
}


// ═══════════════════════════════════════════════════════════════
// UpdateService — checks GitHub for new app versions
// ═══════════════════════════════════════════════════════════════
class UpdateService {
  // Current installed version — bump this in storage.dart each release
  static const String currentVersion = '1.0.0';

  // Raw URL of version.json in your GitHub repo
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
        final data = Map<String, dynamic>.from(
            json.decode(resp.body) as Map);
        final latest  = data['version']     as String? ?? currentVersion;
        final url     = data['downloadUrl'] as String? ?? '';
        final message = data['message']     as String? ??
            'FarmConnect $latest is available!';

        if (_isNewer(latest, currentVersion)) {
          return {
            'latestVersion': latest,
            'downloadUrl':   url,
            'message':       message,
          };
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

