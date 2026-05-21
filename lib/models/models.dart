import 'package:uuid/uuid.dart';

// ── User ──────────────────────────────────────────────────────────
class UserModel {
  final String id;
  final String name;
  final String phone;
  String passwordHash;
  final String createdAt;
  String? deletedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.passwordHash,
    required this.createdAt,
    this.deletedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id:           j['id']           as String,
    name:         j['name']         as String,
    phone:        j['phone']        as String,
    passwordHash: j['passwordHash'] as String,
    createdAt:    j['createdAt']    as String,
    deletedAt:    j['deletedAt']    as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'phone': phone,
    'passwordHash': passwordHash, 'createdAt': createdAt,
    'deletedAt': deletedAt,
  };
}

// ── Crop ──────────────────────────────────────────────────────────
class CropModel {
  final String id;
  final String name;
  final String variety;
  final String emoji;
  final String field;
  final String county;
  final double area;
  String status;
  final String plantedDate;
  final int expectedDays;
  final String expectedHarvestDate;

  CropModel({
    required this.id,
    required this.name,
    required this.variety,
    required this.emoji,
    required this.field,
    required this.county,
    required this.area,
    required this.status,
    required this.plantedDate,
    required this.expectedDays,
    required this.expectedHarvestDate,
  });

  int get daysToHarvest {
    try {
      final p = expectedHarvestDate.split('/');
      if (p.length < 3) return 0;
      final harvest = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      return harvest.difference(DateTime.now()).inDays;
    } catch (_) { return 0; }
  }

  factory CropModel.fromJson(Map<String, dynamic> j) => CropModel(
    id:                  j['id']                  as String,
    name:                j['name']                as String,
    variety:             (j['variety']            as String?) ?? '',
    emoji:               (j['emoji']              as String?) ?? '🌱',
    field:               (j['field']              as String?) ?? '',
    county:              (j['county']             as String?) ?? '',
    area:                (j['area']               as num?)?.toDouble() ?? 0.0,
    status:              (j['status']             as String?) ?? 'growing',
    plantedDate:         (j['plantedDate']        as String?) ?? '',
    expectedDays:        (j['expectedDays']       as num?)?.toInt() ?? 90,
    expectedHarvestDate: (j['expectedHarvestDate'] as String?) ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'variety': variety, 'emoji': emoji,
    'field': field, 'county': county, 'area': area, 'status': status,
    'plantedDate': plantedDate, 'expectedDays': expectedDays,
    'expectedHarvestDate': expectedHarvestDate,
  };
}

// ── Livestock ─────────────────────────────────────────────────────
class LivestockModel {
  final String id;
  final String type;
  final String breed;
  final String emoji;
  final int count;
  final String notes;
  final String createdAt;
  final String county;

  LivestockModel({
    required this.id,
    required this.type,
    required this.breed,
    required this.emoji,
    required this.count,
    this.notes = '',
    required this.createdAt,
    this.county = '',
  });

  factory LivestockModel.fromJson(Map<String, dynamic> j) => LivestockModel(
    id:        j['id']        as String,
    type:      j['type']      as String,
    breed:     (j['breed']    as String?) ?? '',
    emoji:     (j['emoji']    as String?) ?? '🐄',
    count:     (j['count']    as num?)?.toInt() ?? 1,
    notes:     (j['notes']    as String?) ?? '',
    createdAt: (j['createdAt'] as String?) ?? '',
    county:    (j['county']   as String?) ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'breed': breed, 'emoji': emoji,
    'count': count, 'notes': notes, 'createdAt': createdAt, 'county': county,
  };
}

// ── Task ──────────────────────────────────────────────────────────
class TaskModel {
  final String id;
  final String title;
  final String category;
  final String dueDate;
  final String priority;
  final String cropId;
  final String createdAt;
  bool completed;

  TaskModel({
    required this.id,
    required this.title,
    this.category = 'General',
    required this.dueDate,
    this.priority = 'medium',
    this.cropId = '',
    required this.createdAt,
    this.completed = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> j) => TaskModel(
    id:        j['id']        as String,
    title:     j['title']     as String,
    category:  (j['category'] as String?) ?? 'General',
    dueDate:   (j['dueDate']  as String?) ?? '',
    priority:  (j['priority'] as String?) ?? 'medium',
    cropId:    (j['cropId']   as String?) ?? '',
    createdAt: (j['createdAt'] as String?) ?? '',
    completed: (j['completed'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'category': category, 'dueDate': dueDate,
    'priority': priority, 'cropId': cropId, 'createdAt': createdAt,
    'completed': completed,
  };
}

// ── Financial Record ──────────────────────────────────────────────
class RecordModel {
  final String id;
  final String type;        // income / expense
  final double amount;
  final String description; // main label
  final String date;
  final String cropName;    // linked crop (optional)
  final String createdAt;

  RecordModel({
    required this.id,
    required this.type,
    required this.amount,
    this.description = '',
    required this.date,
    this.cropName = '',
    required this.createdAt,
  });

  // Legacy compat: 'note' and 'category' -> description
  factory RecordModel.fromJson(Map<String, dynamic> j) => RecordModel(
    id:          j['id']          as String,
    type:        j['type']        as String,
    amount:      (j['amount']     as num?)?.toDouble() ?? 0.0,
    description: (j['description'] as String?)
                  ?? (j['note']     as String?)
                  ?? (j['category'] as String?) ?? '',
    date:        (j['date']       as String?) ?? '',
    cropName:    (j['cropName']   as String?) ?? '',
    createdAt:   (j['createdAt']  as String?) ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'amount': amount, 'description': description,
    'date': date, 'cropName': cropName, 'createdAt': createdAt,
  };
}
