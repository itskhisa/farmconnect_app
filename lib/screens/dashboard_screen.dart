import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/theme.dart';
import '../utils/storage.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int, {int farmTab}) onNavigate;
  final ScrollController? scrollController;
  final VoidCallback? onShowNotifications;
  const DashboardScreen({
    super.key,
    required this.onNavigate,
    this.scrollController,
    this.onShowNotifications,
  });
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user      = StorageService.instance.getCurrentUser();
    final fname     = (user?.name ?? 'Farmer').split(' ').first;
    final counties  = StorageService.instance.getCounties();
    final crops     = StorageService.instance.getCrops();
    final livestock = StorageService.instance.getLivestock();
    final tasks     = StorageService.instance.getTasks();
    final records   = StorageService.instance.getRecords();
    final today     = DateFormat('EEEE, d MMM y').format(DateTime.now());

    final activeCrops = crops.where((c) => c.status != 'harvested').toList();

    DateTime parseDate(String s) {
      try {
        final p = s.split('/');
        return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      } catch (_) { return DateTime(2099); }
    }

    final pendingTasks = tasks.where((t) => !t.completed).toList()
      ..sort((a, b) => parseDate(a.dueDate).compareTo(parseDate(b.dueDate)));

    final dueTodayTasks = pendingTasks.where((t) {
      try {
        final p = t.dueDate.split('/');
        final d = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
        final now = DateTime.now();
        return d.year == now.year && d.month == now.month && d.day == now.day;
      } catch (_) { return false; }
    }).toList();

    final revenue  = records.where((r) => r.type == 'income').fold(0.0, (s, r) => s + r.amount);
    final expenses = records.where((r) => r.type == 'expense').fold(0.0, (s, r) => s + r.amount);
    final net      = revenue - expenses;
    final fmt      = NumberFormat('#,###');

    final upcoming = activeCrops
        .where((c) => c.daysToHarvest >= 0 && c.daysToHarvest <= 60)
        .toList()
      ..sort((a, b) => a.daysToHarvest.compareTo(b.daysToHarvest));

    // Correct area: max per field+county key
    final fieldAreaMap = <String, double>{};
    for (final cr in crops) {
      final key = '${cr.field}||${cr.county}';
      if ((fieldAreaMap[key] ?? 0.0) < cr.area) fieldAreaMap[key] = cr.area;
    }
    final totalArea = fieldAreaMap.values.fold(0.0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          // ── Gradient header — NO BELL ────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: kGreenDark,
            titleSpacing: 0,
            title: Text('FarmConnect',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 22),
                onPressed: widget.onShowNotifications,
                tooltip: 'Notifications',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kGreenDark, kGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Hello, $fname! 👋',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 22, fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          activeCrops.isEmpty
                              ? 'No crops yet — add your first crop'
                              : '${activeCrops.length} active crop${activeCrops.length == 1 ? '' : 's'}  ·  ${totalArea.toStringAsFixed(1)} acres',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85)),
                        ),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 13, color: Colors.white70),
                          const SizedBox(width: 5),
                          Text(today,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, color: Colors.white70)),
                          const SizedBox(width: 16),
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: Colors.white70),
                          const SizedBox(width: 5),
                          Expanded(child: Text(
                            counties.isEmpty ? 'Kenya' : counties.join(', '),
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, color: Colors.white70),
                          )),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),

            ),
          ),

          // ── Quick actions ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                _quickBtn(context, '🌱', 'Add Crop',   kGreen,
                    () => widget.onNavigate(3, farmTab: 0)),
                const SizedBox(width: 8),
                _quickBtn(context, '📋', 'Add Task',   kBlue,
                    () => widget.onNavigate(3, farmTab: 2)),
                const SizedBox(width: 8),
                _quickBtn(context, '💰', 'Add Record', kOrange,
                    () => widget.onNavigate(3, farmTab: 3)),
              ]),
            ),
          ),

          // ── Stats grid ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SectionHeader(title: 'Farm Overview', icon: '📊'),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2, childAspectRatio: 2.1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8, mainAxisSpacing: 8,
                  children: [
                    StatTile(label: 'Revenue',
                        value: 'KSh ${fmt.format(revenue)}', color: kGreen),
                    StatTile(label: 'Expenses',
                        value: 'KSh ${fmt.format(expenses)}', color: kOrange),
                    StatTile(label: 'Active Crops',
                        value: '${activeCrops.length}', color: kBlue),
                    StatTile(label: 'Livestock',
                        value: '${livestock.length}', color: kAmber),
                    StatTile(label: 'Farm Area',
                        value: '${totalArea.toStringAsFixed(1)} ac',
                        color: kGreen),
                    StatTile(label: 'Pending Tasks',
                        value: '${pendingTasks.length}', color: kPurple),
                  ],
                ),
                const SizedBox(height: 8),
                FarmCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  child: Row(children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Net Income',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: kTextMuted)),
                      Text('KSh ${fmt.format(net)}',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 17, fontWeight: FontWeight.w800,
                              color: net >= 0 ? kGreen : kRed)),
                    ]),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => widget.onNavigate(3, farmTab: 3),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                            color: kGreen.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('+ Add Record',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, color: kGreen,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          ),

          // ── Today's reminders ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                SectionHeader(
                  title: 'Reminders  (${dueTodayTasks.length} due today)',
                  icon: '⏰',
                  actionLabel: '+ Add Task',
                  onAction: () => widget.onNavigate(3, farmTab: 2),
                ),
                if (pendingTasks.isEmpty)
                  const FarmCard(child: EmptyState(
                      emoji: '✅', title: 'All clear!',
                      subtitle: 'No tasks due today.'))
                else
                  FarmCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: (dueTodayTasks.isNotEmpty
                              ? dueTodayTasks
                              : pendingTasks)
                          .take(4)
                          .map((t) => _taskRow(context, t))
                          .toList(),
                    ),
                  ),
              ]),
            ),
          ),

          // ── Upcoming harvests ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                SectionHeader(
                  title: 'Upcoming Harvests',
                  icon: '🌾',
                  actionLabel: 'Manage →',
                  onAction: () => widget.onNavigate(3, farmTab: 0),
                ),
                if (upcoming.isEmpty)
                  FarmCard(child: EmptyState(
                    emoji: '🌱', title: 'No harvests tracked',
                    subtitle: 'Add crops to see upcoming harvest dates.',
                    buttonLabel: 'Add Crop',
                    onButton: () => widget.onNavigate(3, farmTab: 0),
                  ))
                else
                  FarmCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: upcoming
                        .take(5).map((c) => _harvestRow(context, c)).toList()),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickBtn(BuildContext context, String emoji, String label,
      Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ]),
        ),
      ),
    );
  }

  Widget _taskRow(BuildContext context, TaskModel t) {
    final priColors = {'high': kRed, 'medium': kAmber, 'low': kGreen};
    final crops = StorageService.instance.getCrops();
    final relatedCrop = t.cropId.isNotEmpty
        ? crops.where((c) => c.id == t.cropId).firstOrNull
        : null;
    final parts = <String>[t.category];
    if (relatedCrop != null) {
      parts.add('${relatedCrop.emoji} ${relatedCrop.name}');
    }
    parts.add('Due ${t.dueDate}');

    final divColor = Theme.of(context).dividerColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: divColor))),
      child: Row(children: [
        Container(
            width: 4, height: 36,
            decoration: BoxDecoration(
                color: priColors[t.priority] ?? kAmber,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.title,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600)),
          Text(parts.join('  ·  '),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: kTextMuted),
              overflow: TextOverflow.ellipsis),
        ])),
        PriorityChip(priority: t.priority),
      ]),
    );
  }

  Widget _harvestRow(BuildContext context, CropModel c) {
    final days = c.daysToHarvest;
    final tagColor = days <= 3
        ? kRed
        : days <= 7
            ? kGreen
            : days <= 21
                ? kAmber
                : kBlue;
    final tagLabel = days <= 0 ? 'Ready!' : '${days}d';
    final divColor = Theme.of(context).dividerColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: divColor))),
      child: Row(children: [
        Text(c.emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${c.name}  —  ${c.variety}',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600)),
          Text('📍 ${c.county.isEmpty ? c.field : c.county}',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: kTextMuted)),
        ])),
        TagChip(
            label: tagLabel,
            bg: tagColor.withOpacity(0.14),
            fg: tagColor),
      ]),
    );
  }
}
