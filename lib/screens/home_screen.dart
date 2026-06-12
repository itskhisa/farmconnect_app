import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';
import '../utils/storage.dart';
import '../utils/notification_service.dart';
import 'dashboard_screen.dart';
import 'farm_management_screen.dart';
import 'other_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _idx = 0;
  int _farmTab = 0;
  int _prevIdx = 0;
  int _farmKey = 0;
  bool _isOffline = false;
  bool _notifDot = false;
  List<Map<String, String>> _notifications = [];

  final List<ScrollController> _scrollControllers =
      List.generate(7, (_) => ScrollController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationService.instance.init().then((_) {
      NotificationService.instance.scheduleDailyWeatherReminder();
    });
    _checkConnectivity();
    _loadNotifications();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      StorageService.instance.logout();
    }
    // Re-check connectivity when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _checkConnectivity();
    }
  }

  void _loadNotifications() {
    // Check if user cleared notifications recently
    final prefs2 = StorageService.instance.prefs;
    final clearedAt = prefs2.getString('notifs_cleared_at');
    final userId = StorageService.instance.getCurrentUserId() ?? 'guest';
    final clearedKey = 'notifs_cleared_at_$userId';
    final clearedAtUser = prefs2.getString(clearedKey);

    final tasks = StorageService.instance.getTasks()
        .where((t) => !t.completed).toList();
    final crops = StorageService.instance.getCrops()
        .where((c) => c.status != 'harvested').toList();
    final today = DateTime.now();

    final notifs = <Map<String, String>>[];

    // Tasks due within 3 days
    for (final t in tasks) {
      try {
        final p = t.dueDate.split('/');
        final d = DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
        if (d.difference(today).inDays <= 3) {
          notifs.add({
            'title': t.category == 'Vaccination'
                ? '💉 Vaccination Due' : '✅ Task Due',
            'body': t.title,
            'due': t.dueDate,
          });
        }
      } catch (_) {}
    }

    // Crops with <= 3 days to harvest
    for (final c in crops) {
      final days = c.daysToHarvest;
      if (days >= 0 && days <= 3) {
        notifs.add({
          'title': days == 0 ? '🌾 Ready to Harvest!' : '🌾 Harvest in ${days}d',
          'body': '${c.name} (${c.variety}) — ${c.field}',
          'due': c.expectedHarvestDate,
        });
        // Schedule device notification
        try {
          final parts = c.expectedHarvestDate.split('/');
          final harvestDate = DateTime(
              int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          NotificationService.instance.scheduleTaskReminder(
            id: c.id.hashCode,
            title: '🌾 Harvest: ${c.name}',
            body: '${c.variety} in ${c.field} is ready!',
            scheduledDate: harvestDate,
          );
        } catch (_) {}
      }
    }

    // Filter out individually dismissed notifications using fingerprints
    // A fingerprint = title+body+due combined — unique per notification
    final userId2 = StorageService.instance.getCurrentUserId() ?? 'guest';
    final dismissedKey = 'dismissed_notifs_$userId2';
    final dismissed = (StorageService.instance.prefs.getStringList(dismissedKey) ?? []).toSet();
    final visibleNotifs = notifs.where((n) {
      final fp = '${n['title']}|${n['body']}|${n['due']}';
      return !dismissed.contains(fp);
    }).toList();
    if (mounted) setState(() {
      _notifications = visibleNotifs;
      _notifDot = visibleNotifs.isNotEmpty;
    });
  }

  void _showNotifications(BuildContext context) {
    setState(() => _notifDot = false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Row(children: [
            Text('Notifications',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (_notifications.isNotEmpty)
              TextButton(
                onPressed: () async {
                  final uid = StorageService.instance.getCurrentUserId() ?? 'guest';
                  final dismissedKey = 'dismissed_notifs_$uid';
                  // Save each notification's fingerprint so it stays dismissed
                  final fps = _notifications.map((n) => '${n["title"]}|${n["body"]}|${n["due"]}').toList();
                  final existing = StorageService.instance.prefs
                      .getStringList(dismissedKey) ?? [];
                  existing.addAll(fps);
                  await StorageService.instance.prefs
                      .setStringList(dismissedKey, existing);
                  setState(() { _notifications = []; _notifDot = false; });
                  Navigator.pop(context);
                },
                child: Text('Clear all',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: kGreen))),
          ]),
          const SizedBox(height: 8),
          if (_notifications.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(children: [
                const Text('✅', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text('All clear!',
                    style: GoogleFonts.plusJakartaSans(color: kTextMuted)),
              ]),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView(shrinkWrap: true,
                children: _notifications.map((n) => ListTile(
                  leading: Text(n['title']!.split(' ').first,
                      style: const TextStyle(fontSize: 22)),
                  title: Text(n['title']!.split(' ').skip(1).join(' '),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                  subtitle: Text('${n['body']}  ·  ${n['due']}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                  dense: true,
                )).toList()),
            ),
        ]),
      ),
    );
  }

  Future<void> _checkConnectivity() async {
    // Only show offline banner when user manually enables Offline Mode.
    // Do NOT use HTTP requests to detect connectivity — they fail on Android
    // even when WiFi is connected (carrier filtering, timeouts, etc.)
    final prefs = await SharedPreferences.getInstance();
    final manualOffline = prefs.getBool('pref_offline') ?? false;
    if (mounted) setState(() => _isOffline = manualOffline);
    // Re-check every 30 seconds in case user toggles offline mode from Profile
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) _checkConnectivity();
    });
  }

  void goTo(int index, {int farmTab = 0}) {
    setState(() {
      _prevIdx = _idx;
      _idx = index;
      if (index == 3) { _farmTab = farmTab; _farmKey++; }
    });
    final sc = _scrollControllers[index];
    if (sc.hasClients) {
      sc.animateTo(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
    }
    _loadNotifications();
  }

  Future<bool> _onWillPop() async {
    if (_idx != 0) {
      setState(() {
        _idx = (_prevIdx == _idx) ? 0 : _prevIdx;
        _prevIdx = 0;
      });
      return false;
    }
    final exit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Exit FarmConnect?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to exit?',
            style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: kGreen),
              child: const Text('Exit')),
        ],
      ),
    );
    if (exit == true) SystemNavigator.pop();
    return false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final sc in _scrollControllers) sc.dispose();
    super.dispose();
  }

  @override


  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const tabs = [
      (Icons.home_outlined,          'Home'),
      (Icons.storefront_outlined,    'Market'),
      (Icons.cloud_outlined,         'Weather'),
      (Icons.grass_outlined,         'Farm'),
      (Icons.construction_outlined,  'Tools'),
      (Icons.forum_outlined,         'Community'),
      (Icons.person_outline_rounded, 'Profile'),
    ];

    final screens = [
      DashboardScreen(
        scrollController: _scrollControllers[0],
        onNavigate: (i, {int? farmTab}) => goTo(i, farmTab: farmTab ?? 0),
        onShowNotifications: () => _showNotifications(context),
      ),
      MarketScreen(scrollController: _scrollControllers[1]),
      WeatherScreen(scrollController: _scrollControllers[2]),
      FarmManagementScreen(
        key: ValueKey('farm_${_farmTab}_$_farmKey'),
        initialTab: _farmTab,
        onDataChanged: _loadNotifications,
      ),
      ToolsHubScreen(scrollController: _scrollControllers[4]),
      CommunityScreen(scrollController: _scrollControllers[5]),
      ProfileScreen(
        onNavigate: goTo,
        scrollController: _scrollControllers[6],
        onPrefsChanged: () { _checkConnectivity(); },
      ),
    ];

    // Nav bar colors — fully dark-mode aware
    final navBg     = Theme.of(context).cardColor;
    final navBorder = isDark
        ? const Color(0xFF2A4A2D)
        : const Color(0xFFD6E8D8);
    final activeColor   = kGreen;
    final inactiveColor = isDark
        ? const Color(0xFF5A7A5D)
        : const Color(0xFF9BA8B5);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(children: [
          if (_isOffline)
            SafeArea(
              bottom: false,
              child: Material(
                color: const Color(0xFFF59E0B),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  child: Row(children: [
                    const Icon(Icons.wifi_off, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                        'Offline mode is on — weather and prices may be outdated',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: Colors.white,
                            fontWeight: FontWeight.w600))),
                    GestureDetector(
                        onTap: _checkConnectivity,
                        child: const Icon(Icons.refresh,
                            size: 16, color: Colors.white)),
                  ]),
                ),
              ),
            ),
          Expanded(child: IndexedStack(index: _idx, children: screens)),
        ]),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: navBg,
            border: Border(top: BorderSide(color: navBorder)),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final active = _idx == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => goTo(i),
                      behavior: HitTestBehavior.opaque,
                      child: Stack(alignment: Alignment.center, children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 3, width: active ? 28 : 0,
                            decoration: BoxDecoration(
                              color: activeColor,
                              borderRadius: BorderRadius.circular(2)),
                          ),
                          const SizedBox(height: 4),
                          Icon(tabs[i].$1, size: 22,
                              color: active ? activeColor : inactiveColor),
                          const SizedBox(height: 2),
                          Text(tabs[i].$2,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: active ? activeColor : inactiveColor,
                              )),
                        ]),
                      ]),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
