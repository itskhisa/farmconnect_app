import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../utils/theme.dart';
import '../utils/storage.dart';
import '../models/models.dart';
import '../data/farm_data.dart';
import '../widgets/widgets.dart';

class FarmManagementScreen extends StatefulWidget {
  final int initialTab;
  final VoidCallback? onDataChanged;
  const FarmManagementScreen({super.key, this.initialTab = 0, this.onDataChanged});
  @override
  State<FarmManagementScreen> createState() => _FarmManagementScreenState();
}

class _FarmManagementScreenState extends State<FarmManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this, initialIndex: widget.initialTab);
    // Fetch latest data from cloud on screen open
    _syncFromCloud();
  }

  Future<void> _syncFromCloud() async {
    await Future.wait([
      StorageService.instance.fetchCrops(),
      StorageService.instance.fetchTasks(),
      StorageService.instance.fetchRecords(),
      StorageService.instance.fetchLivestock(),
    ]);
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(FarmManagementScreen old) {
    super.didUpdateWidget(old);
    if (old.initialTab != widget.initialTab) {
      _tabs.animateTo(widget.initialTab);
    }
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  void _refresh() {
    setState(() {});
    widget.onDataChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Farm Management'),
        backgroundColor: Theme.of(context).cardColor,
        bottom: TabBar(
          controller: _tabs,
          labelColor: kGreen,
          unselectedLabelColor: kTextMuted,
          indicatorColor: kGreen,
          indicatorWeight: 2.5,
          labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
          tabs: const [
            Tab(text: 'Crops'),
            Tab(text: 'Livestock'),
            Tab(text: 'Tasks'),
            Tab(text: 'Records'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _CropsTab(onRefresh: _refresh),
          _LivestockTab(onRefresh: _refresh),
          _TasksTab(onRefresh: _refresh),
          _RecordsTab(onRefresh: _refresh),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// CROPS TAB
// ════════════════════════════════════════════════════════════════

class _CropsTab extends StatelessWidget {
  final VoidCallback onRefresh;
  const _CropsTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final crops = StorageService.instance.getCrops();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCropDialog(context, onRefresh),
        backgroundColor: kGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Crop',
            style: GoogleFonts.plusJakartaSans(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: crops.isEmpty
          ? EmptyState(
              emoji: '🌱', title: 'No crops yet',
              subtitle: 'Tap + Add Crop to start tracking your fields.',
              buttonLabel: 'Add Crop',
              onButton: () => _showAddCropDialog(context, onRefresh),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: crops.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final c = crops[i];
                final days = c.daysToHarvest;
                // Detect intercropping: another crop shares same field + county
                final isIntercropped = crops.where((other) =>
                    other.id != c.id &&
                    other.field == c.field &&
                    other.county == c.county).isNotEmpty;
                final fieldLabel = '${c.field}${c.county.isNotEmpty ? ' — ' + c.county : ''}';
                return FarmCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(c.emoji, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(c.name + '  —  ' + c.variety,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14, fontWeight: FontWeight.w700))),
                          if (isIntercropped)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: kGreen.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: kGreen.withOpacity(0.3)),
                              ),
                              child: Text('🌿 Intercropped',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10, color: kGreen,
                                      fontWeight: FontWeight.w700)),
                            ),
                        ]),
                        Text('📍 ' + fieldLabel,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, color: kTextMuted)),
                      ])),
                      StatusChip(status: c.status),
                    ]),
                    const Divider(height: 16),
                    Row(children: [
                      _stat('📐', c.area.toString() + ' acres'),
                      _stat('📅', 'Planted ' + c.plantedDate),
                      _stat('🌾', days <= 0 ? 'Ready!' : days.toString() + 'd left'),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(
                        onPressed: () => _showEditStatusDialog(context, c, onRefresh),
                        child: Text('Edit Status',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, color: kBlue)),
                      ),
                      TextButton(
                        onPressed: () => _confirmDelete(context, c.id, onRefresh),
                        child: Text('Delete',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, color: kRed)),
                      ),
                    ]),
                  ]),
                );
              },
            ),
    );
  }

  Widget _stat(String icon, String val) => Expanded(
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 4),
      Expanded(child: Text(val,
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: kTextSec),
          overflow: TextOverflow.ellipsis)),
    ]),
  );

  void _confirmDelete(BuildContext ctx, String id, VoidCallback refresh) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: Text('Delete Crop?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
      content: Text('This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(color: kTextSec)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kRed),
          onPressed: () async {
            await StorageService.instance.deleteCrop(id);
            Navigator.pop(ctx); refresh();
          },
          child: const Text('Delete'),
        ),
      ],
    ));
  }
}


// ── Shared calendar date picker widget ───────────────────────────
Widget _buildDateField({
  required BuildContext ctx,
  required TextEditingController controller,
  required StateSetter setS,
  required String label,
  String? errorText,
  DateTime? firstDate,
  DateTime? lastDate,
  bool allowFuture = true,
  bool allowPast = true,
}) {
  final now = DateTime.now();
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    RichText(text: TextSpan(children: [
      TextSpan(text: label, style: GoogleFonts.plusJakartaSans(
          fontSize: 13, fontWeight: FontWeight.w600, color: kTextSec)),
      const TextSpan(text: ' *',
          style: TextStyle(color: kRed, fontSize: 13, fontWeight: FontWeight.w700)),
    ])),
    const SizedBox(height: 6),
    GestureDetector(
      onTap: () async {
        DateTime initial;
        try {
          initial = controller.text.isNotEmpty
              ? DateFormat('dd/MM/yyyy').parseStrict(controller.text)
              : now;
        } catch (_) { initial = now; }
        final picked = await showDatePicker(
          context: ctx,
          initialDate: initial.isAfter(lastDate ?? initial) ? (lastDate ?? initial)
                     : initial.isBefore(firstDate ?? initial) ? (firstDate ?? initial)
                     : initial,
          firstDate: firstDate ?? DateTime(2020),
          lastDate: lastDate ?? DateTime(2030),
          builder: (c, child) => Theme(
            data: Theme.of(c).copyWith(
              colorScheme: Theme.of(c).brightness == Brightness.dark
                ? const ColorScheme.dark(primary: kGreen, onPrimary: Colors.white, surface: Color(0xFF1A2E1C), onSurface: Colors.white)
                : const ColorScheme.light(primary: kGreen, onPrimary: Colors.white, onSurface: Colors.black87)),
            child: child!,
          ),
        );
        if (picked != null) setS(() => controller.text = DateFormat('dd/MM/yyyy').format(picked));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(ctx).brightness == Brightness.dark ? const Color(0xFF152017) : kInputBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: errorText != null ? kRed : Theme.of(ctx).dividerColor),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 18, color: kTextMuted),
          const SizedBox(width: 10),
          Expanded(child: Text(
            controller.text.isEmpty ? 'Tap to select date' : controller.text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: controller.text.isEmpty ? Theme.of(ctx).hintColor : Theme.of(ctx).textTheme.bodyLarge!.color!,
            ),
          )),
          const Icon(Icons.arrow_drop_down, color: kTextMuted),
        ]),
      ),
    ),
    if (errorText != null) Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(errorText, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: kRed)),
    ),
  ]);
}

void _showAddCropDialog(BuildContext context, VoidCallback refresh) {
  final counties = StorageService.instance.getCounties();
  String selectedCrop = (kCropVarieties.keys.toList()..sort()).first;
  String selectedVariety = kCropVarieties[selectedCrop]!.first;
  String selectedCounty = counties.isNotEmpty ? counties.first : kKenyaCounties.first;

  bool isEstablished = false;
  final fieldCtrl   = TextEditingController();
  final areaCtrl    = TextEditingController();
  final daysCtrl    = TextEditingController(
      text: getCropDefaultDays(selectedCrop).toString());
  final plantedCtrl = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));

  String? fieldErr, areaErr, daysErr, dateErr;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Container(
        height: MediaQuery.of(ctx).size.height * 0.88,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Handle
          Container(margin: const EdgeInsets.only(top: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: kBorder, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(children: [
              Text('Add New Crop',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close)),
            ]),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Crop type
                Text('Crop Type', style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: kTextSec)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedCrop,
                  decoration: const InputDecoration(),
                  items: (kCropVarieties.keys.toList()..sort()).map((c) =>
                      DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setS(() {
                    selectedCrop = v!;
                    selectedVariety = kCropVarieties[v]!.first;
                    isEstablished = false;
                    daysCtrl.text = getCropDefaultDays(v).toString();
                  }),
                ),
                const SizedBox(height: 14),

                // Variety
                Text('Variety', style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: kTextSec)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedVariety,
                  decoration: const InputDecoration(),
                  items: (kCropVarieties[selectedCrop] ?? []).map((v) =>
                      DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setS(() => selectedVariety = v!),
                ),
                const SizedBox(height: 14),

                // If perennial - established toggle
                if (cropHasTwoModes(selectedCrop)) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kAmber.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kAmber.withOpacity(0.3)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('🌳  Tree/Bush Status',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, fontWeight: FontWeight.w700, color: kAmber)),
                      const SizedBox(height: 8),
                      Text(getCropHarvestNote(selectedCrop),
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: kTextSec, height: 1.4)),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: GestureDetector(
                          onTap: () => setS(() {
                            isEstablished = false;
                            daysCtrl.text = getCropDefaultDays(selectedCrop, isEstablished: false).toString();
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !isEstablished ? kGreen : kBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: !isEstablished ? kGreen : kBorder),
                            ),
                            child: Center(child: Text('New Planting',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12, fontWeight: FontWeight.w600,
                                    color: !isEstablished ? Colors.white : kTextSec))),
                          ),
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: GestureDetector(
                          onTap: () => setS(() {
                            isEstablished = true;
                            daysCtrl.text = getCropDefaultDays(selectedCrop, isEstablished: true).toString();
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isEstablished ? kGreen : kBg,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isEstablished ? kGreen : kBorder),
                            ),
                            child: Center(child: Text('Already Growing',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12, fontWeight: FontWeight.w600,
                                    color: isEstablished ? Colors.white : kTextSec))),
                          ),
                        )),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 14),
                ],
                // Field name with intercrop detection
                Builder(builder: (ctx2) {
                  // Build ALL field+county combinations (not just unique field names)
                  final allCrops = StorageService.instance.getCrops();
                  // Use field+county as unique key
                  final fieldCountySet = <String>{};
                  final fieldCountyList = <Map<String,String>>[];
                  for (final cr in allCrops) {
                    final key = cr.field + '||' + cr.county;
                    if (fieldCountySet.add(key)) {
                      fieldCountyList.add({'field': cr.field, 'county': cr.county, 'area': cr.area.toString()});
                    }
                  }
                  fieldCountyList.sort((a,b) => (a['field']!+a['county']!).compareTo(b['field']!+b['county']!));
                  // Keep existingFields for backward compat
                  final existingFields = fieldCountyList.map((m) => m['field']!).toList();
                  // Map field -> area for auto-fill (by field+county key)
                  final fieldAreaMap = <String, double>{};
                  for (final cr in allCrops) {
                    fieldAreaMap[cr.field + '||' + cr.county] = cr.area;
                    fieldAreaMap[cr.field] = cr.area; // fallback
                  }
                  // Intercrop: same field name in same county
                  final isIntercrop = fieldCtrl.text.trim().isNotEmpty &&
                      StorageService.instance.getCrops().any((c) =>
                        c.field == fieldCtrl.text.trim() &&
                        c.county == selectedCounty);
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    LabelledField(
                      label: 'Field Name', hint: 'e.g. Field A, North Plot',
                      controller: fieldCtrl, errorText: fieldErr,
                      isRequired: true),
                    if (existingFields.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Tap to use existing field (intercrop):',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: kTextMuted)),
                      const SizedBox(height: 4),
                      Wrap(spacing: 6, runSpacing: 4,
                        children: fieldCountyList.map((fc) {
                          final field = fc['field']!;
                          final county = fc['county']!;
                          final label = field + (county.isNotEmpty ? ' — ' + county : '');
                          final key = field + '||' + county;
                          final isSelected = fieldCtrl.text.trim() == field &&
                              selectedCounty == county;
                          return GestureDetector(
                            onTap: () => setS(() {
                              fieldCtrl.text = field;
                              if (county.isNotEmpty) selectedCounty = county;
                              if (fieldAreaMap.containsKey(key)) {
                                areaCtrl.text = fieldAreaMap[key].toString();
                              } else if (fieldAreaMap.containsKey(field)) {
                                areaCtrl.text = fieldAreaMap[field].toString();
                              }
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? kGreen.withOpacity(0.15) : kBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? kGreen : kBorder),
                              ),
                              child: Text(label,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: isSelected ? kGreen : kTextSec,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400)),
                            ),
                          );
                        }).toList()),
                    ],
                    if (isIntercrop)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kGreen.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kGreen.withOpacity(0.3)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.merge_type_rounded, color: kGreen, size: 16),
                            const SizedBox(width: 6),
                            Expanded(child: Text(
                              '🌿 Intercropping on existing field. Area will not be counted twice.',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: kGreen))),
                          ]),
                        ),
                      ),
                  ]);
                }),
                const SizedBox(height: 14),

                // County
                Text('County / Location', style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: kTextSec)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedCounty,
                  decoration: const InputDecoration(),
                  items: (counties.isNotEmpty ? counties : kKenyaCounties)
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setS(() => selectedCounty = v!),
                ),
                const SizedBox(height: 14),

                // Area
                LabelledField(
                  label: 'Area (acres)', hint: 'e.g. 2.5',
                  controller: areaCtrl, errorText: areaErr,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 14),

                // Planted date - calendar picker
                RichText(text: TextSpan(children: [
                  TextSpan(text: 'Planted Date', style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w600, color: kTextSec)),
                  const TextSpan(text: ' *', style: TextStyle(color: kRed, fontSize: 13, fontWeight: FontWeight.w700)),
                ])),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).brightness == Brightness.dark
                            ? const ColorScheme.dark(primary: kGreen, onPrimary: Colors.white, surface: Color(0xFF1A2E1C), onSurface: Colors.white)
                            : const ColorScheme.light(primary: kGreen, onPrimary: Colors.white, onSurface: Colors.black87),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setS(() {
                        plantedCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
                        dateErr = null;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).brightness == Brightness.dark ? const Color(0xFF152017) : kInputBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dateErr != null ? kRed : Theme.of(ctx).dividerColor),
                    ),
                    child: Row(children: [
                      Icon(Icons.calendar_today_outlined, size: 18, color: Theme.of(ctx).hintColor),
                      const SizedBox(width: 10),
                      Expanded(child: Text(
                        plantedCtrl.text.isEmpty ? 'Tap to select date' : plantedCtrl.text,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: plantedCtrl.text.isEmpty ? Theme.of(ctx).hintColor : Theme.of(ctx).textTheme.bodyLarge!.color!,
                        ),
                      )),
                      Icon(Icons.arrow_drop_down, color: Theme.of(ctx).hintColor),
                    ]),
                  ),
                ),
                if (dateErr != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(dateErr!, style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: kRed)),
                  ),
                const SizedBox(height: 14),

                // Planting advice — always shown
                Builder(builder: (ctx) {
                  DateTime plantDate;
                  try {
                    final parts = plantedCtrl.text.split('/');
                    plantDate = parts.length == 3
                        ? DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]))
                        : DateTime.now();
                  } catch (_) {
                    plantDate = DateTime.now();
                  }
                  final advice = getPlantingAdvice(selectedCrop, selectedCounty, plantDate);
                  if (advice == null) return const SizedBox.shrink();
                  final isGood = (advice['isGoodMonth'] as bool) && !(advice['isPoorCounty'] as bool);
                  return Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isGood ? ctx.tGreenPale : (ctx.isDark ? const Color(0xFF2A1800) : kAmber.withOpacity(0.08)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isGood ? kGreen.withOpacity(0.3) : kAmber.withOpacity(0.3),
                        ),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('📋  Planting Advice for $selectedCrop',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: isGood ? kGreen : kAmber)),
                        const SizedBox(height: 6),
                        Text(advice['timing'] as String,
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: ctx.tText, height: 1.4)),
                        const SizedBox(height: 4),
                        Text(advice['location'] as String,
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: ctx.tText, height: 1.4)),
                        const SizedBox(height: 4),
                        Text('💡  ' + (advice['tip'] as String),
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: kTextSec, height: 1.4)),
                      ]),
                    ),
                  );
                }),
                // Days to harvest
                LabelledField(
                  label: 'Days to Harvest', hint: 'e.g. 90',
                  controller: daysCtrl, errorText: daysErr,
                  keyboardType: TextInputType.number,
                  helperText: 'Suggested: ' + getCropDefaultDays(selectedCrop).toString() + ' days for ' + selectedCrop,
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setS(() {
                        fieldErr = areaErr = daysErr = dateErr = null;
                        if (fieldCtrl.text.trim().isEmpty)
                          fieldErr = 'Field name is required';
                        final area = double.tryParse(areaCtrl.text);
                        if (area == null || area <= 0)
                          areaErr = 'Enter a valid area (e.g. 2.5)';
                        final days = int.tryParse(daysCtrl.text);
                        if (days == null || days <= 0)
                          daysErr = 'Enter valid days to harvest';
                        try {
                          DateFormat('dd/MM/yyyy').parseStrict(plantedCtrl.text);
                        } catch (_) {
                          dateErr = 'Use DD/MM/YYYY format (e.g. 15/03/2025)';
                        }
                      });
                      if (fieldErr != null || areaErr != null ||
                          daysErr != null || dateErr != null) return;

                      final planted = DateFormat('dd/MM/yyyy')
                          .parseStrict(plantedCtrl.text);
                      final harvest = planted.add(
                          Duration(days: int.parse(daysCtrl.text)));

                      final crop = CropModel(
                        id: const Uuid().v4(),
                        name: selectedCrop,
                        variety: selectedVariety,
                        emoji: kCropEmojis[selectedCrop] ?? '🌱',
                        field: fieldCtrl.text.trim(),
                        county: selectedCounty,
                        area: double.parse(areaCtrl.text),
                        status: 'growing',
                        plantedDate: plantedCtrl.text.trim(),
                        expectedDays: int.parse(daysCtrl.text),
                        expectedHarvestDate: DateFormat('dd/MM/yyyy').format(harvest),
                      );

                      StorageService.instance.addCrop(crop).then((_) {
                        _autoCreateTasks(crop);
                        Navigator.pop(ctx);
                        refresh();
                        showSuccess(context, '${crop.name} added! Tasks auto-created.');
                      });
                    },
                    child: const Text('Add Crop'),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    ),
  );
}

void _autoCreateTasks(CropModel crop) {
  final templates = {
    'Maize':    [('Fertilize (top-dress) — ${crop.field}', 'Fertilizing', 30, 'high'),
                  ('Weed control — ${crop.field}', 'Weeding', 21, 'medium'),
                  ('Harvest ${crop.name} — ${crop.field}', 'Harvesting', -7, 'high')],
    'Beans':    [('Apply fungicide — ${crop.field}', 'Spraying', 14, 'medium'),
                  ('Weed control — ${crop.field}', 'Weeding', 14, 'medium'),
                  ('Harvest ${crop.name} — ${crop.field}', 'Harvesting', -7, 'high')],
    'Tomatoes': [('Apply fertilizer — ${crop.field}', 'Fertilizing', 14, 'high'),
                  ('Spray pesticide — ${crop.field}', 'Spraying', 21, 'medium'),
                  ('Harvest ${crop.name} — ${crop.field}', 'Harvesting', -7, 'high')],
  };

  final defaults = [
    ('Apply fertilizer — ${crop.field}', 'Fertilizing', 30, 'medium'),
    ('Weed control — ${crop.field}', 'Weeding', 21, 'medium'),
    ('Harvest ${crop.name} — ${crop.field}', 'Harvesting', -7, 'high'),
  ];

  final tasks = templates[crop.name] ?? defaults;
  final fmt = DateFormat('dd/MM/yyyy');

  DateTime planted;
  try {
    planted = DateFormat('dd/MM/yyyy').parseStrict(crop.plantedDate);
  } catch (_) { return; }

  for (final t in tasks) {
    DateTime due;
    if (t.$3 < 0) {
      due = planted.add(Duration(days: crop.expectedDays + t.$3));
    } else {
      due = planted.add(Duration(days: t.$3));
    }
    if (due.isBefore(DateTime.now())) {
      due = DateTime.now().add(const Duration(days: 3));
    }
    StorageService.instance.addTask(TaskModel(
      id: const Uuid().v4(),
      title: t.$1,
      category: t.$2,
      dueDate: fmt.format(due),
      priority: t.$4,
      cropId: crop.id,
      createdAt: DateTime.now().toIso8601String(),
    ));
  }
}

void _showEditStatusDialog(BuildContext ctx, CropModel crop, VoidCallback refresh) {
  String status = crop.status;
  showDialog(context: ctx, builder: (_) => StatefulBuilder(
    builder: (ctx2, setS) => AlertDialog(
      title: Text('Update ${crop.name}',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
      content: DropdownButtonFormField<String>(
        value: status,
        decoration: const InputDecoration(labelText: 'Status'),
        items: ['growing', 'flowering', 'ready', 'harvested', 'poor']
            .map((s) => DropdownMenuItem(value: s,
                child: Text(s[0].toUpperCase() + s.substring(1))))
            .toList(),
        onChanged: (v) => setS(() => status = v!),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            crop.status = status;
            await StorageService.instance.updateCrop(crop);
            Navigator.pop(ctx2); refresh();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  ));
}

// ════════════════════════════════════════════════════════════════
// TASKS TAB
// ════════════════════════════════════════════════════════════════

class _TasksTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const _TasksTab({required this.onRefresh});
  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab> {
  String _filter = 'All'; // All, Farm Tasks, Vaccination

  void _refresh() { widget.onRefresh(); setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final allTasks = StorageService.instance.getTasks()
        .where((t) => !t.completed).toList()
      ..sort((a, b) {
        final pri = {'high': 0, 'medium': 1, 'low': 2};
        return (pri[a.priority] ?? 1).compareTo(pri[b.priority] ?? 1);
      });

    final vaccTasks    = allTasks.where((t) => t.category == 'Vaccination').toList();
    final regularTasks = allTasks.where((t) => t.category != 'Vaccination').toList();

    final filtered = _filter == 'All' ? allTasks
        : _filter == 'Vaccination' ? vaccTasks
        : regularTasks;

    final priColor = {'high': kRed, 'medium': kAmber, 'low': kGreen};

    Widget taskCard(TaskModel t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FarmCard(
        child: Row(children: [
          Container(
            width: 4, height: 44,
            decoration: BoxDecoration(
              color: priColor[t.priority] ?? kAmber,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          if (t.category == 'Vaccination')
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.vaccines_outlined, color: kAmber, size: 20),
            ),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.title, style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600)),
            Text(t.category + '  ·  Due ' + t.dueDate,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: kTextMuted)),
          ])),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              await StorageService.instance.completeTask(t.id);
              _refresh();
              showSuccess(context, 'Task completed! 🎉');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: kGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Text('✓ Done', style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: kGreen, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () async {
              await StorageService.instance.deleteTask(t.id);
              _refresh();
            },
            child: const Icon(Icons.close, size: 18, color: kRed),
          ),
        ]),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_filter == 'Vaccination') {
            // Navigate to livestock tab to record vaccination
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Go to Livestock tab → tap an animal to record a vaccination'),
              backgroundColor: kAmber,
            ));
          } else {
            _showAddTaskDialog(context, _refresh);
          }
        },
        backgroundColor: _filter == 'Vaccination' ? kAmber : kGreen,
        icon: Icon(
          _filter == 'Vaccination' ? Icons.vaccines_outlined : Icons.add,
          color: Colors.white),
        label: Text(
          _filter == 'Vaccination' ? 'Add Vaccination' :
          _filter == 'Farm Tasks' ? 'Add Farm Task' : 'Add Task',
          style: GoogleFonts.plusJakartaSans(
              color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Column(children: [
        // Filter tabs - Farm Tasks | Vaccination Reminders | All
        Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(children: [
            for (final tab in [
              ('All', allTasks.length),
              ('Farm Tasks', regularTasks.length),
              ('Vaccination', vaccTasks.length),
            ])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _filter = tab.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _filter == tab.$1 ? kGreen : Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _filter == tab.$1 ? kGreen : Theme.of(context).dividerColor),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (tab.$1 == 'Vaccination')
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.vaccines_outlined, size: 12,
                              color: Colors.white),
                        ),
                      Text(tab.$1, style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: _filter == tab.$1 ? Colors.white : kTextSec,
                          fontWeight: _filter == tab.$1
                              ? FontWeight.w700 : FontWeight.w400)),
                      if (tab.$2 > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: _filter == tab.$1
                                ? Colors.white.withOpacity(0.3)
                                : kGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(tab.$2.toString(),
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: _filter == tab.$1 ? Colors.white : kGreen,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ]),
                  ),
                ),
              ),
          ]),
        ),

        // Task list
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  emoji: _filter == 'Vaccination' ? '💉' : '✅',
                  title: _filter == 'Vaccination'
                      ? 'No vaccination reminders'
                      : 'No pending tasks',
                  subtitle: _filter == 'Vaccination'
                      ? 'Tap an animal in Livestock to record a vaccination.'
                      : 'All done! Add a task to stay on schedule.',
                  buttonLabel: _filter == 'Vaccination' ? null : '+ Add Task',
                  onButton: _filter == 'Vaccination' ? null
                      : () => _showAddTaskDialog(context, _refresh),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  children: filtered.map(taskCard).toList(),
                ),
        ),
      ]),
    );
  }
}

void _showAddTaskDialog(BuildContext context, VoidCallback refresh) {
  final titleCtrl = TextEditingController();
  final dueCtrl   = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  String category = kTaskCategories.first;
  String priority = 'medium';
  String? titleErr, dueErr;

  showModalBottomSheet(
    context: context, isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Add Task', style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              IconButton(onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 14),
            LabelledField(
                label: 'Task Title',
                hint: 'e.g. Apply fertilizer to Field A',
                controller: titleCtrl, errorText: titleErr),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Category', style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: kTextSec)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(),
                  items: kTaskCategories.map((c) =>
                      DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setS(() => category = v!),
                ),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Priority', style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600, color: kTextSec)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(),
                  items: ['high', 'medium', 'low'].map((p) =>
                      DropdownMenuItem(value: p,
                          child: Text(p[0].toUpperCase() + p.substring(1))))
                      .toList(),
                  onChanged: (v) => setS(() => priority = v!),
                ),
              ])),
            ]),
            const SizedBox(height: 12),
            _buildDateField(
                ctx: ctx, controller: dueCtrl, setS: setS,
                label: 'Due Date', errorText: dueErr,
                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 730))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setS(() {
                    titleErr = dueErr = null;
                    if (titleCtrl.text.trim().isEmpty)
                      titleErr = 'Task title is required';
                    if (dueCtrl.text.isEmpty)
                      dueErr = 'Select a due date';
                  });
                  if (titleErr != null || dueErr != null) return;

                  StorageService.instance.addTask(TaskModel(
                    id: const Uuid().v4(),
                    title: titleCtrl.text.trim(),
                    category: category,
                    dueDate: dueCtrl.text.trim(),
                    priority: priority,
                    createdAt: DateTime.now().toIso8601String(),
                  )).then((_) { Navigator.pop(ctx); refresh(); });
                },
                child: const Text('Add Task'),
              ),
            ),
          ]),
        ),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════
// RECORDS TAB
// ════════════════════════════════════════════════════════════════

class _RecordsTab extends StatelessWidget {
  final VoidCallback onRefresh;
  const _RecordsTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final records  = StorageService.instance.getRecords().reversed.toList();
    final revenue  = records.where((r) => r.type == 'income')
        .fold(0.0, (s, r) => s + r.amount);
    final expenses = records.where((r) => r.type == 'expense')
        .fold(0.0, (s, r) => s + r.amount);
    final fmt = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(children: [
        // Summary
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: FarmCard(
              color: kGreen,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Total Income',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: Colors.white70)),
                Text('KSh ${fmt.format(revenue)}',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 17, fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ]),
            )),
            const SizedBox(width: 10),
            Expanded(child: FarmCard(
              color: kOrange,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Total Expenses',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: Colors.white70)),
                Text('KSh ${fmt.format(expenses)}',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 17, fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ]),
            )),
          ]),
        ),
        // Add buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: () => _showAddRecordDialog(context, 'income', onRefresh),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen, minimumSize: const Size(0, 44)),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Income'),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(
              onPressed: () => _showAddRecordDialog(context, 'expense', onRefresh),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kRed, minimumSize: const Size(0, 44)),
              icon: const Icon(Icons.remove, size: 16),
              label: const Text('Expense'),
            )),
          ]),
        ),
        // Records list
        Expanded(
          child: records.isEmpty
              ? const EmptyState(
                  emoji: '💰', title: 'No records yet',
                  subtitle: 'Track your income and expenses here.')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final r = records[i];
                    final isIncome = r.type == 'income';
                    return FarmCard(
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: isIncome
                                ? context.tGreenPale
                                : kRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Icon(
                            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isIncome ? kGreen : kRed, size: 18,
                          )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(r.description,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('${r.cropName.isEmpty ? '' : '${r.cropName}  ·  '}${r.date}',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11, color: kTextMuted)),
                        ])),
                        Text('${isIncome ? '+' : '-'}KSh ${fmt.format(r.amount)}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14, fontWeight: FontWeight.w800,
                                color: isIncome ? kGreen : kRed)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: ctx,
                              builder: (_) => AlertDialog(
                                title: Text('Delete Record?',
                                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                                content: Text('This cannot be undone.',
                                    style: GoogleFonts.plusJakartaSans()),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel')),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(backgroundColor: kRed),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await StorageService.instance.deleteRecord(r.id);
                              onRefresh();
                            }
                          },
                          child: const Icon(Icons.delete_outline, size: 18, color: kRed),
                        ),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

void _showAddRecordDialog(BuildContext context, String type, VoidCallback refresh) {
  final amtCtrl  = TextEditingController();
  final descCtrl = TextEditingController();
  final dateCtrl = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  final crops = StorageService.instance.getCrops();
  final lst   = StorageService.instance.getLivestock();
  String? selectedRelated;
  String? amtErr, descErr, dateErr;
  final isIncome = type == 'income';

  showModalBottomSheet(
    context: context, isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isIncome ? context.tGreenPale : kRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(isIncome ? '+ Income' : '- Expense',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: isIncome ? kGreen : kRed)),
                ),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close)),
              ]),
              const SizedBox(height: 14),

              // Amount
              LabelledField(
                  label: 'Amount (KSh)',
                  hint: 'e.g. 5000',
                  controller: amtCtrl,
                  errorText: amtErr,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  numbersOnly: true),
              const SizedBox(height: 12),

              // Description
              LabelledField(
                  label: 'Description',
                  hint: isIncome ? 'e.g. Maize sale at Wakulima' : 'e.g. Fertilizer purchase',
                  controller: descCtrl,
                  errorText: descErr,
                  isRequired: true),
              const SizedBox(height: 12),

              // Date — calendar picker
              Text('Date *', style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: kTextSec)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                        colorScheme: Theme.of(c).brightness == Brightness.dark
                          ? const ColorScheme.dark(primary: kGreen, onPrimary: Colors.white)
                          : const ColorScheme.light(primary: kGreen, onPrimary: Colors.white, onSurface: Colors.black87),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setS(() {
                      dateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
                      dateErr = null;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).inputDecorationTheme.fillColor ?? Theme.of(ctx).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: dateErr != null ? kRed : Theme.of(ctx).dividerColor),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today_outlined, size: 18,
                        color: Theme.of(ctx).hintColor),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      dateCtrl.text.isEmpty ? 'Tap to select date' : dateCtrl.text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: dateCtrl.text.isEmpty
                            ? Theme.of(ctx).hintColor
                            : Theme.of(ctx).textTheme.bodyLarge?.color,
                      ),
                    )),
                    Icon(Icons.arrow_drop_down, color: Theme.of(ctx).hintColor),
                  ]),
                ),
              ),
              if (dateErr != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(dateErr!,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: Colors.red)),
                ),

              // Related crop or livestock
              if (crops.isNotEmpty || lst.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Related Crop or Livestock (optional)',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: kTextSec)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedRelated,
                  decoration: const InputDecoration(
                      hintText: 'Select crop or livestock'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...crops.map((cr) {
                      final lbl = cr.emoji + '  ' + cr.name
                          + (cr.variety.isNotEmpty ? ' (${cr.variety})' : '')
                          + (cr.field.isNotEmpty ? ' — ${cr.field}' : '')
                          + (cr.county.isNotEmpty ? ', ${cr.county}' : '');
                      return DropdownMenuItem(value: lbl, child: Text(lbl));
                    }),
                    ...lst.map((l) {
                      final lbl = l.emoji + '  ' + l.type
                          + (l.breed.isNotEmpty ? ' (${l.breed})' : '')
                          + (l.county.isNotEmpty ? ' — ${l.county}' : '');
                      return DropdownMenuItem(value: lbl, child: Text(lbl));
                    }),
                  ],
                  onChanged: (v) => setS(() => selectedRelated = v),
                ),
              ],
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isIncome ? kGreen : kRed),
                  onPressed: () {
                    setS(() {
                      amtErr = descErr = dateErr = null;
                      final amt = double.tryParse(amtCtrl.text);
                      if (amt == null || amt <= 0)
                        amtErr = 'Enter a valid positive amount';
                      if (descCtrl.text.trim().isEmpty)
                        descErr = 'Description is required';
                      if (dateCtrl.text.isEmpty)
                        dateErr = 'Select a date';
                    });
                    if (amtErr != null || descErr != null || dateErr != null) return;

                    StorageService.instance.addRecord(RecordModel(
                      id: const Uuid().v4(),
                      type: type,
                      amount: double.parse(amtCtrl.text),
                      description: descCtrl.text.trim(),
                      date: dateCtrl.text.trim(),
                      cropName: selectedRelated ?? '',
                      createdAt: DateTime.now().toIso8601String(),
                    )).then((_) { Navigator.pop(ctx); refresh(); });
                  },
                  child: Text(isIncome ? 'Add Income' : 'Add Expense'),
                ),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    ),
  );
}

class _LivestockTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const _LivestockTab({required this.onRefresh});
  @override
  State<_LivestockTab> createState() => _LivestockTabState();
}

class _LivestockTabState extends State<_LivestockTab> {
  @override
  Widget build(BuildContext context) {
    final lst = StorageService.instance.getLivestock();
    final uniqueTypes = lst.map((l) => l.type).toSet().toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLivestockDialog(context, () {
          widget.onRefresh();
          setState(() {});
        }),
        backgroundColor: kGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Livestock', style: GoogleFonts.plusJakartaSans(
            color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: lst.isEmpty
          ? EmptyState(
              emoji: '🐄', title: 'No livestock yet',
              subtitle: 'Track your animals here.',
              buttonLabel: 'Add Livestock',
              onButton: () => _showAddLivestockDialog(context, () {
                widget.onRefresh(); setState(() {});
              }),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // Livestock list
                const SectionHeader(title: 'My Livestock', icon: '🐄'),
                const SizedBox(height: 8),
                ...List.generate(lst.length, (i) {
                  final l = lst[i];
                  final vacCount = getVaccinationSchedule(l.type).length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                      if (getVaccinationSchedule(l.type).isNotEmpty) {
                        _showVaccinationDialog(context, l, () => setState(() {}));
                      }
                    },
                      child: FarmCard(
                        child: Row(children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                                color: kAmber.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text(l.emoji,
                                style: const TextStyle(fontSize: 26))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(l.type, style: GoogleFonts.plusJakartaSans(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                            Text(l.breed + '  ·  ' + l.count.toString() + ' animals',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12, color: kTextSec)),
                            if (l.notes.isNotEmpty)
                              Text(l.notes, style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11, color: kTextMuted)),
                            if (getVaccinationSchedule(l.type).isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(children: [
                                  const Icon(Icons.vaccines_outlined, size: 12, color: kAmber),
                                  const SizedBox(width: 3),
                                  Text('Tap to record vaccination',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11, color: kAmber,
                                          fontWeight: FontWeight.w600)),
                                ]),
                              ),
                          ])),
                          GestureDetector(
                            onTap: () async {
                              await StorageService.instance.deleteLivestock(l.id);
                              widget.onRefresh();
                              setState(() {});
                            },
                            child: const Icon(Icons.close, color: kRed, size: 18),
                          ),
                        ]),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}


int _intervalToDays(String interval) {
  final s = interval.toLowerCase();
  if (s.contains('month')) {
    final n = RegExp(r'(\d+)').firstMatch(s)?.group(1);
    return (int.tryParse(n ?? '6') ?? 6) * 30;
  }
  if (s.contains('week')) {
    final n = RegExp(r'(\d+)').firstMatch(s)?.group(1);
    return (int.tryParse(n ?? '4') ?? 4) * 7;
  }
  if (s.contains('annual') || s.contains('year') || s.contains('once')) return 365;
  if (s.contains('6') && s.contains('month')) return 180;
  if (s.contains('3') && s.contains('month')) return 90;
  return 365;
}

void _showVaccinationDialog(BuildContext context, LivestockModel animal, VoidCallback refresh) {
  final vaccinations = StorageService.instance.getVaccinationRecords()
      .where((r) => r['livestockId'] == animal.id)
      .toList();
  final schedule = getVaccinationSchedule(animal.type);
  final vaccCtrl  = TextEditingController();
  final notesCtrl = TextEditingController();
  String? selectedVaccine = schedule.isNotEmpty ? schedule.first['vaccine'] as String : null;
  DateTime givenDate = DateTime.now();
  DateTime? nextDueDate;

  showModalBottomSheet(
    context: context, isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(animal.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(child: Text('${animal.type} Vaccinations',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16, fontWeight: FontWeight.w800))),
                IconButton(onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close)),
              ]),
              const Divider(),

              // Past vaccinations
              if (vaccinations.isNotEmpty) ...[
                Text('Vaccination History',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w700, color: kGreen)),
                const SizedBox(height: 8),
                ...vaccinations.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: FarmCard(
                    color: context.tGreenPale,
                    child: Row(children: [
                      const Icon(Icons.check_circle, color: kGreen, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(v['vaccineName'] as String,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                        Text('Given: ' + (v['givenDate'] as String) +
                            (v['nextDueDate'] != null && (v['nextDueDate'] as String).isNotEmpty
                                ? '  ·  Next due: ' + (v['nextDueDate'] as String) : ''),
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF9EC4A2) : kTextSec)),
                      ])),
                      GestureDetector(
                        onTap: () async {
                          await StorageService.instance.deleteVaccinationRecord(v['id'] as String);
                          Navigator.pop(ctx);
                          refresh();
                        },
                        child: const Icon(Icons.close, size: 16, color: kRed),
                      ),
                    ]),
                  ),
                )),
                const SizedBox(height: 8),
                const Divider(),
              ],

              // Record new vaccination
              Text('Record New Vaccination',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: Theme.of(ctx).brightness == Brightness.dark
                          ? const Color(0xFFE8F5EA) : kText)),
              const SizedBox(height: 12),

              // Vaccine selection
              Text('Vaccine Name', style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: Theme.of(ctx).brightness == Brightness.dark
                      ? const Color(0xFF9EC4A2) : kTextSec)),
              const SizedBox(height: 6),
              if (schedule.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: selectedVaccine,
                  decoration: const InputDecoration(hintText: 'Select vaccine'),
                  items: schedule.map((v) => DropdownMenuItem(
                      value: v['vaccine'] as String,
                      child: Text(v['vaccine'] as String))).toList(),
                  onChanged: (v) => setS(() {
                    selectedVaccine = v;
                    vaccCtrl.text = v ?? '';
                    // Auto-set next due date based on interval string
                    final intervalStr = schedule.firstWhere(
                        (s) => s['vaccine'] == v, orElse: () => {'interval': 'Annually'})['interval'] as String? ?? 'Annually';
                    nextDueDate = givenDate.add(Duration(days: _intervalToDays(intervalStr)));
                  }),
                ),
                const SizedBox(height: 4),
                Text('Or type a custom vaccine name:',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: kTextMuted)),
              ],
              const SizedBox(height: 6),
              LabelledField(
                  label: 'Custom Vaccine (optional)',
                  hint: 'e.g. FMD, Newcastle, Anthrax',
                  controller: vaccCtrl),
              const SizedBox(height: 12),

              // Date given
              Text('Date Given', style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: Theme.of(ctx).brightness == Brightness.dark
                      ? const Color(0xFF9EC4A2) : kTextSec)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: givenDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                        colorScheme: Theme.of(c).brightness == Brightness.dark
                            ? const ColorScheme.dark(
                                primary: kGreen, onPrimary: Colors.white,
                                surface: Color(0xFF1A2E1C), onSurface: Color(0xFFE8F5EA))
                            : const ColorScheme.light(
                                primary: kGreen, onPrimary: Colors.white, onSurface: kText),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setS(() {
                      givenDate = picked;
                      // Recalculate next due
                      if (selectedVaccine != null) {
                        final intervalStr = schedule.firstWhere(
                            (s) => s['vaccine'] == selectedVaccine,
                            orElse: () => {'interval': 'Annually'})['interval'] as String? ?? 'Annually';
                        nextDueDate = picked.add(Duration(days: _intervalToDays(intervalStr)));
                      }
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).brightness == Brightness.dark
                        ? const Color(0xFF152017) : kInputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(ctx).brightness == Brightness.dark
                          ? const Color(0xFF2A4A2D) : kBorder),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 18, color: kTextMuted),
                    const SizedBox(width: 10),
                    Text(DateFormat('dd/MM/yyyy').format(givenDate),
                        style: GoogleFonts.plusJakartaSans(fontSize: 14)),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: kTextMuted),
                  ]),
                ),
              ),
              const SizedBox(height: 12),

              // Next due date (auto-calculated but editable)
              Text('Next Due Date (for reminder)',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: Theme.of(ctx).brightness == Brightness.dark
                          ? const Color(0xFF9EC4A2) : kTextSec)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: nextDueDate ?? DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                        colorScheme: Theme.of(c).brightness == Brightness.dark
                            ? const ColorScheme.dark(
                                primary: kGreen, onPrimary: Colors.white,
                                surface: Color(0xFF1A2E1C), onSurface: Color(0xFFE8F5EA))
                            : const ColorScheme.light(
                                primary: kGreen, onPrimary: Colors.white, onSurface: kText),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setS(() => nextDueDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: nextDueDate != null
                        ? (Theme.of(ctx).brightness == Brightness.dark
                            ? const Color(0xFF1A3A1C) : kGreenPale)
                        : (Theme.of(ctx).brightness == Brightness.dark
                            ? const Color(0xFF152017) : kInputBg),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: nextDueDate != null
                          ? kGreen.withOpacity(0.3)
                          : (Theme.of(ctx).brightness == Brightness.dark
                              ? const Color(0xFF2A4A2D) : kBorder)),
                  ),
                  child: Row(children: [
                    Icon(Icons.alarm_outlined, size: 18,
                        color: nextDueDate != null ? kGreen : kTextMuted),
                    const SizedBox(width: 10),
                    Text(
                      nextDueDate != null
                          ? DateFormat('dd/MM/yyyy').format(nextDueDate!)
                          : 'Tap to set reminder date',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: nextDueDate != null ? kGreen : kTextHint,
                          fontWeight: nextDueDate != null ? FontWeight.w600 : FontWeight.w400),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: kTextMuted),
                  ]),
                ),
              ),
              if (nextDueDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('A reminder task will be created automatically',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: kGreen)),
                ),
              const SizedBox(height: 12),

              LabelledField(label: 'Notes (optional)',
                  hint: 'e.g. dose, vet name, batch number',
                  controller: notesCtrl),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.vaccines_outlined, size: 16),
                  label: const Text('Save Vaccination Record'),
                  onPressed: () async {
                    final vacName = vaccCtrl.text.trim().isNotEmpty
                        ? vaccCtrl.text.trim()
                        : selectedVaccine ?? 'Vaccination';
                    final record = {
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'livestockId': animal.id,
                      'animalType': animal.type,
                      'vaccineName': vacName,
                      'givenDate': DateFormat('dd/MM/yyyy').format(givenDate),
                      'nextDueDate': nextDueDate != null
                          ? DateFormat('dd/MM/yyyy').format(nextDueDate!) : '',
                      'notes': notesCtrl.text.trim(),
                    };
                    await StorageService.instance.addVaccinationRecord(record);
                    Navigator.pop(ctx);
                    refresh();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Vaccination recorded!' +
                            (nextDueDate != null ? ' Reminder set for ' +
                                DateFormat('dd/MM/yyyy').format(nextDueDate!) : '')),
                        backgroundColor: kGreen,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    ),
  );
}

void _showAddLivestockDialog(BuildContext context, VoidCallback refresh) {
  final farmerCounties = StorageService.instance.getCounties();
  final counties       = farmerCounties.isNotEmpty ? farmerCounties : kKenyaCounties;
  String selectedType  = (kLivestockTypes.keys.toList()..sort()).first;
  String selectedBreed = (kLivestockTypes[selectedType]!['breeds'] as List<dynamic>).first;
  String selectedCounty = counties.first;
  final countCtrl      = TextEditingController();
  final notesCtrl      = TextEditingController();
  String? countErr;

  showModalBottomSheet(
    context: context, isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Add Livestock', style: GoogleFonts.plusJakartaSans(
                fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Text('Animal Type', style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: Theme.of(ctx).brightness == Brightness.dark
                    ? const Color(0xFF9EC4A2) : kTextSec)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(),
              items: kLivestockTypes.keys.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text('${kLivestockTypes[t]!['emoji']}  $t'))).toList(),
              onChanged: (v) => setS(() {
                selectedType  = v!;
                selectedBreed = (kLivestockTypes[v]!['breeds'] as List<dynamic>).first;
              }),
            ),
            const SizedBox(height: 12),
            Text('Breed', style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: Theme.of(ctx).brightness == Brightness.dark
                    ? const Color(0xFF9EC4A2) : kTextSec)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedBreed,
              decoration: const InputDecoration(),
              items: (kLivestockTypes[selectedType]!['breeds'] as List<dynamic>)
                  .map((b) => DropdownMenuItem(value: b.toString(),
                      child: Text(b.toString()))).toList(),
              onChanged: (v) => setS(() => selectedBreed = v!),
            ),
            const SizedBox(height: 10),

            // County selector
            Text('County', style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: Theme.of(ctx).brightness == Brightness.dark
                    ? const Color(0xFF9EC4A2) : kTextSec)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedCounty,
              decoration: const InputDecoration(),
              items: kKenyaCounties.map((co) =>
                  DropdownMenuItem(value: co, child: Text(co))).toList(),
              onChanged: (v) => setS(() => selectedCounty = v!),
            ),
            const SizedBox(height: 10),

            // Suitability advice
            Builder(builder: (ctx2) {
              final advice = getLivestockSuitability(selectedType, selectedCounty);
              if (advice == null) return const SizedBox.shrink();
              final isGood = advice['isGood'] as bool;
              final isPoor = advice['isPoor'] as bool;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPoor
                        ? kRed.withOpacity(0.08)
                        : isGood
                            ? (Theme.of(ctx2).brightness == Brightness.dark
                                ? const Color(0xFF1A3A1C) : kGreenPale)
                            : (Theme.of(ctx2).brightness == Brightness.dark
                                ? const Color(0xFF2A1800) : kAmber.withOpacity(0.08)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isPoor ? kRed.withOpacity(0.3)
                          : isGood ? kGreen.withOpacity(0.3)
                          : kAmber.withOpacity(0.3)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(advice['icon'] + '  ' + (advice['suitability'] as String),
                        style: GoogleFonts.plusJakartaSans(fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isPoor ? kRed : isGood ? kGreen : kAmber)),
                    const SizedBox(height: 6),
                    Text('💡  ' + (advice['tip'] as String),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: Theme.of(ctx2).brightness == Brightness.dark
                                ? const Color(0xFF9EC4A2) : kTextSec,
                            height: 1.4)),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 12),
            LabelledField(label: 'Number of Animals', hint: 'e.g. 5',
                controller: countCtrl, errorText: countErr,
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            LabelledField(label: 'Notes (optional)',
                hint: 'e.g. 3 pregnant, vaccinated',
                controller: notesCtrl, maxLines: 2),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setS(() {
                    countErr = null;
                    final c = int.tryParse(countCtrl.text);
                    if (c == null || c <= 0)
                      countErr = 'Enter a valid number of animals';
                  });
                  if (countErr != null) return;
                  StorageService.instance.addLivestock(LivestockModel(
                    id: const Uuid().v4(),
                    type: selectedType,
                    breed: selectedBreed,
                    emoji: kLivestockTypes[selectedType]!['emoji'] as String,
                    count: int.parse(countCtrl.text),
                    notes: notesCtrl.text.trim(),
                    createdAt: DateTime.now().toIso8601String(),
                  )).then((_) { Navigator.pop(ctx); refresh(); });
                },
                child: const Text('Add Livestock'),
              ),
            ),
          ]),
        ),
        ),
      ),
    ),
  );
}
