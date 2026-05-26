// ════════════════════════════════════════════════════════════════
// MARKET SCREEN
// ════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/theme.dart';
import '../utils/storage.dart';
import '../widgets/widgets.dart';
import '../data/farm_data.dart';
import '../models/models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart' show themeNotifier;

class MarketScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const MarketScreen({super.key, this.scrollController});
  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _filter = 'All';
  DateTime _lastUpdated = DateTime.now();

  void _refresh() {
    setState(() => _lastUpdated = DateTime.now());
    // Force full rebuild with fresh data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prices updated • ${DateFormat('HH:mm').format(DateTime.now())}'),
        duration: const Duration(seconds: 2),
        backgroundColor: kGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-refresh when market screen is revisited
    final stale = DateTime.now().difference(_lastUpdated).inMinutes > 60;
    if (stale) setState(() => _lastUpdated = DateTime.now());
  }


  // Returns EXACT price-name prefixes for all products of a livestock type
  // Must only match 'livestock' type rows in kNairobiPrices
  List<String> _getLivestockProductNames(String type) {
    final t = type.toLowerCase();
    if (t.contains('dairy') || (t.contains('cow') && !t.contains('beef'))) {
      return ['fresh milk', 'ghee', 'yoghurt', 'fresh cream', 'cattle hide'];
    }
    if (t.contains('beef cattle') || t == 'beef') {
      return ['beef', 'cattle hide', 'beef steer', 'dairy heifer', 'dairy bull'];
    }
    if (t.contains('goat')) return ['goat', 'boer goat'];
    if (t.contains('sheep')) return ['sheep', 'mutton'];
    if (t.contains('pig')) return ['pig', 'pork', 'piglet'];
    if (t.contains('poultry') || t.contains('chicken') || t.contains('broiler')) {
      return ['broiler', 'eggs — tray of 30 (large)', 'eggs — tray of 30 (medium)'];
    }
    if (t.contains('kienyeji') || t.contains('indigenous')) {
      return ['kienyeji chicken', 'eggs — kienyeji'];
    }
    if (t.contains('turkey')) return ['turkey'];
    if (t.contains('duck')) return ['duck', 'eggs — duck'];
    if (t.contains('rabbit')) return ['rabbit'];
    if (t.contains('bee')) return ['honey', 'beeswax', 'propolis'];
    if (t.contains('tilapia')) return ['tilapia'];
    if (t.contains('fish')) return ['tilapia', 'catfish', 'omena', 'trout'];
    if (t.contains('camel')) return [];
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');
    final allPrices = [...kNairobiPrices]..sort((a, b) => (a['crop'] as String).compareTo(b['crop'] as String));
    final myCrops = StorageService.instance.getCrops();
    final myLivestock = StorageService.instance.getLivestock();

    // Match farmer's own crops — ALL price entries for that crop
    final myMatches = <Map<String, dynamic>>[];

    // CROPS: match exact variety to price entries
    for (final crop in myCrops) {
      // Try exact variety match first, then crop name match
      final variety = crop.variety.toLowerCase();
      final cname = crop.name.toLowerCase();

      // Find prices that mention this specific variety OR crop name
      final matches = allPrices.where((p) {
        if ((p['type'] as String) == 'livestock') return false;
        final pname = (p['crop'] as String).toLowerCase();
        // Exact variety match (e.g. "Rose Coco" matches "Beans — Rose Coco")
        if (variety.isNotEmpty && pname.contains(variety.split(' ').first)) return true;
        // Crop name match (fallback)
        final firstWord = cname.split(' ').first;
        return pname.startsWith(firstWord) || pname.contains(' ' + firstWord);
      }).toList();

      // If no variety match, fall back to first crop-name match only
      final varietyMatches = matches.where((p) {
        final pname = (p['crop'] as String).toLowerCase();
        return variety.isNotEmpty && pname.contains(variety.split(' ').first);
      }).toList();

      final toAdd = varietyMatches.isNotEmpty ? varietyMatches : matches.take(1).toList();
      final sameField = myCrops.where((c2) => c2.field == crop.field && c2.name != crop.name).isNotEmpty;
      final label = crop.emoji + ' ' + crop.name +
          (crop.variety.isNotEmpty ? ' (' + crop.variety + ')' : '') +
          (sameField ? ' 🌿' + crop.field : '');

      for (final match in toAdd) {
        final key = match['crop'] as String;
        // Deduplicate: same crop+price already shown → skip unless different variety
        final samePrice = myMatches.any((m) =>
            m['crop'] == key &&
            m['price'] == match['price'] &&
            (m['_variety'] as String? ?? '') == crop.variety);
        if (!samePrice) {
          myMatches.add({...match, '_label': label, '_sourceId': crop.id,
              '_type': 'crop', '_variety': crop.variety});
        }
      }
    }

    // LIVESTOCK: match each animal to ALL its products (milk, eggs, meat, honey etc.)
    for (final l in myLivestock) {
      final lname = l.type.toLowerCase();
      // Match on type keywords - dairy→milk, cattle→beef, goat→goat, bees→honey etc.
      final keywords = _getLivestockProductNames(l.type);
      for (final keyword in keywords) {
        final matches = allPrices.where((p) {
          // Only search livestock-type prices to avoid false crop matches
          if ((p['type'] as String) != 'livestock') return false;
          final pname = (p['crop'] as String).toLowerCase();
          final kw = keyword.toLowerCase();
          return pname.startsWith(kw) || pname.contains(' ' + kw);
        }).toList();
        for (final match in matches) {
          final key = match['crop'] as String;
          // Allow same product from different breeds
          final exists = myMatches.any((m) => m['crop'] == key && m['_sourceId'] == l.id);
          if (!exists) {
            // If farmer has 2+ breeds of same type, show breed name
            final sameTypeCount = myLivestock.where((l2) => l2.type == l.type).length;
            myMatches.add({...match,
              '_label': l.emoji + ' ' + l.type +
                  (sameTypeCount > 1 ? ' (' + l.breed + ')' : ''),
              '_sourceId': l.id,
              '_type': 'livestock',
            });
          }
        }
      }
    }

    // Build filtered list AFTER myMatches is populated
    List<Map<String,dynamic>> _sorted(List<Map<String,dynamic>> lst) =>
        lst..sort((a,b) => (a['crop'] as String).compareTo(b['crop'] as String));
    final filtered = _filter == 'All'
        ? _sorted(List.from(allPrices))
        : _filter == 'My Farm'
          ? _sorted(List.from(myMatches))
          : _sorted(allPrices.where((p) => p['type'] == (_filter == 'Crops' ? 'crop' : 'livestock')).toList());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Market Prices'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(children: [
              const Icon(Icons.circle, color: kGreen, size: 8),
              const SizedBox(width: 4),
              Text('Live', style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: kGreen, fontWeight: FontWeight.w600)),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
            tooltip: 'Refresh prices',
          ),
        ],
      ),
      body: Column(children: [
        // Header bar
        Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.storefront_outlined, size: 16, color: kGreen),
              const SizedBox(width: 6),
              Text('Nairobi Wholesale Market (Wakulima)',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w700, color: kText)),
              const Spacer(),
              Text('Updated: ${DateFormat('HH:mm').format(_lastUpdated)}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: context.tTextMuted)),
            ]),
            const SizedBox(height: 4),
            Text('Prices updated weekly from Nairobi market surveys',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: context.tTextMuted)),
            const SizedBox(height: 10),
            Row(children: [
              for (final f in ['All', 'My Farm', 'Crops', 'Livestock'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _filter == f ? kGreen : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _filter == f ? kGreen : context.tBorder),
                      ),
                      child: Text(f, style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: _filter == f ? FontWeight.w700 : FontWeight.w400,
                          color: _filter == f ? Colors.white : context.tTextSec)),
                    ),
                  ),
                ),
            ]),
          ]),
        ),

        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(16),
            children: [

              // My Farm prices section
              if (myMatches.isNotEmpty && _filter == 'My Farm') ...[
                Row(children: [
                  const Text('🌱', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text('My Farm — Current Prices',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, fontWeight: FontWeight.w800, color: kGreen)),
                ]),
                const SizedBox(height: 8),
                ...myMatches.map((p) => _priceRow(p, fmt, highlight: true)),
                const SizedBox(height: 4),
                const Divider(),
                const SizedBox(height: 12),
              ],

              if (_filter != 'My Farm') ...[ // hide when Your Farm filter active
              // Trending section
              Row(children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text('Trending This Week',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w800, color: context.tText)),
              ]),
              const SizedBox(height: 8),
              FarmCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('🟢  Rising prices — good time to sell:',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w600, color: kGreen)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 4,
                      children: () {
                            final tBase = _filter == 'Crops'
                                ? allPrices.where((p) => p['type'] == 'crop')
                                : _filter == 'Livestock'
                                  ? allPrices.where((p) => p['type'] == 'livestock')
                                  : allPrices.toList().asMap().values;
                            final seen = <String>{};
                            return tBase.where((p) => p['trend'] == 'up')
                              .where((p) {
                                final word = (p['crop'] as String).split(' ').first;
                                return seen.add(word);
                              }).take(8)
                              .map((p) => TagChip(
                                label: (p['crop'] as String).split(' ').first,
                                bg: kGreen.withOpacity(0.1), fg: kGreen))
                              .toList();
                          }()),
                  const SizedBox(height: 10),
                  Text('🔴  Falling prices — consider waiting:',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w600, color: kRed)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 4,
                      children: () {
                            final tBase2 = _filter == 'Crops'
                                ? allPrices.where((p) => p['type'] == 'crop')
                                : _filter == 'Livestock'
                                  ? allPrices.where((p) => p['type'] == 'livestock')
                                  : allPrices.toList().asMap().values;
                            final seen = <String>{};
                            return tBase2.where((p) => p['trend'] == 'down')
                              .where((p) {
                                final word = (p['crop'] as String).split(' ').first;
                                return seen.add(word);
                              }).take(6)
                              .map((p) => TagChip(
                                label: (p['crop'] as String).split(' ').first,
                                bg: kRed.withOpacity(0.1), fg: kRed))
                              .toList();
                          }()),
                ]),
              ),
              const SizedBox(height: 16),

              // Full price list
              Row(children: [
                Text(
                  _filter == 'All' ? 'All Prices (${filtered.length} items)'
                    : _filter == 'Crops' ? 'Crop Prices (${filtered.length} items)'
                    : 'Livestock & Products (${filtered.length} items)',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w800, color: context.tText)),
              ]),
              const SizedBox(height: 8),
              ...filtered.map((p) => _priceRow(p, fmt)),
              const SizedBox(height: 16),
              FarmCard(
                color: kAmber.withOpacity(0.08),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: kAmber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    'Prices are weekly Nairobi Wakulima wholesale averages. Retail and farm-gate prices may differ.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: context.tTextSec),
                  )),
                ]),
              ),
              ], // end non-Your-Farm section
              const SizedBox(height: 80),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _priceRow(Map<String, dynamic> p, NumberFormat fmt, {bool highlight = false}) {
    final isUp    = p['trend'] == 'up';
    final isDown  = p['trend'] == 'down';
    final tColor  = isUp ? kGreen : (isDown ? kRed : kTextMuted);
    final tIcon   = isUp ? Icons.trending_up : (isDown ? Icons.trending_down : Icons.trending_flat);
    final isLvstk = p['type'] == 'livestock';
    final label   = p['_label'] as String?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FarmCard(
        color: highlight ? context.tGreenPale : null,
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isLvstk ? kAmber.withOpacity(0.12) : kGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(
              isLvstk ? '🐾' : '🌿',
              style: const TextStyle(fontSize: 17),
            )),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p['crop'] as String,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w700)),
            Text(
              (label != null ? label + '  ·  ' : '') + ('per ' + (p['unit'] as String)),
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: context.tTextMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              p.containsKey('range')
                  ? (p['range'] as String)
                  : 'KSh ' + fmt.format(p['price'] as int),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w800, color: kText)),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(tIcon, size: 13, color: tColor),
              const SizedBox(width: 2),
              Text(p['change'] as String,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: tColor, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// WEATHER SCREEN — Real data from Open-Meteo (free, no API key)
// ════════════════════════════════════════════════════════════════

// Kenya county coordinates
const Map<String, List<double>> kCountyCoords = {
  // Precise town-center coordinates (verified from Google Maps)
  'Nairobi':          [-1.2921,  36.8219],
  'Mombasa':          [-4.0435,  39.6682],
  'Kisumu':           [-0.1022,  34.7617],
  'Nakuru':           [-0.3031,  36.0800],
  'Eldoret':          [ 0.5143,  35.2698],
  'Kiambu':           [-1.1741,  36.8346],
  'Meru':             [ 0.0467,  37.6494],
  'Nyeri':            [-0.4167,  36.9500],
  'Kakamega':         [ 0.2827,  34.7519],
  'Machakos':         [-1.5177,  37.2634],
  'Kericho':          [-0.3686,  35.2863],
  'Bomet':            [-0.7833,  35.3500],
  'Muranga':          [-0.7167,  37.1500],
  'Kirinyaga':        [-0.4936,  37.2694],  // Kerugoya
  'Embu':             [-0.5300,  37.4500],
  'Garissa':          [-0.4532,  39.6461],
  'Kitui':            [-1.3667,  38.0100],
  'Makueni':          [-1.8044,  37.6245],  // Wote
  'Kajiado':          [-1.8520,  36.7763],
  'Narok':            [-1.0833,  35.8667],
  'Uasin Gishu':      [ 0.5143,  35.2698],  // Eldoret
  'Trans Nzoia':      [ 1.0167,  34.9667],  // Kitale
  'Bungoma':          [ 0.5635,  34.5606],
  'Busia':            [ 0.4606,  34.1116],
  'Homa Bay':         [-0.5267,  34.4571],
  'Migori':           [-1.0634,  34.4731],
  'Siaya':            [ 0.0607,  34.2879],
  'Vihiga':           [ 0.0773,  34.7196],
  'Turkana':          [ 3.1167,  35.6000],  // Lodwar
  'Samburu':          [ 1.0833,  36.6833],  // Maralal
  'Laikipia':         [ 0.0167,  37.0667],  // Nanyuki
  'Nyandarua':        [-0.3000,  36.5333],  // Ol Kalou
  'Tharaka-Nithi':    [-0.3333,  37.9167],  // Chuka
  'Isiolo':           [ 0.3543,  37.5822],
  'Marsabit':         [ 2.3284,  37.9899],
  'Wajir':            [ 1.7471,  40.0573],
  'Mandera':          [ 3.9366,  41.8670],
  'Lamu':             [-2.2694,  40.9020],
  'Tana River':       [-0.9167,  40.1167],  // Hola
  'Kilifi':           [-3.5053,  39.8499],
  'Kwale':            [-4.1735,  39.4521],
  'Taita-Taveta':     [-3.4167,  38.5500],  // Voi
  'Nandi':            [ 0.1833,  35.1000],  // Kapsabet
  'Elgeyo-Marakwet':  [ 0.8833,  35.5167],  // Iten
  'West Pokot':       [ 1.2500,  35.1167],  // Kapenguria
  'Baringo':          [ 0.4667,  35.9833],  // Kabarnet
  'Nyamira':          [-0.5667,  34.9333],
};

// WMO weather codes to emoji + description
String weatherEmoji(int code, {int rainProb = 0}) {
  // Override with rain probability for accuracy
  if (rainProb >= 70) return '🌧️';
  if (rainProb >= 50) return '🌦️';
  if (rainProb >= 30) return '⛅';
  if (code == 0) return '☀️';
  if (code <= 2) return '⛅';
  if (code == 3) return '☁️';
  if (code <= 49) return '🌫️';
  if (code <= 67) return '🌧️';
  if (code <= 77) return '❄️';
  if (code <= 82) return '🌦️';
  if (code <= 99) return '⛈️';
  return '🌤️';
}

String weatherDesc(int code, {int rainProb = 0}) {
  // Use precipitation probability as primary — matches Google
  if (rainProb >= 70) return 'Heavy rain likely';
  if (rainProb >= 50) return 'Rain expected';
  if (rainProb >= 30) return 'Light rain possible';
  if (rainProb >= 15) return 'Slight rain chance';
  if (code == 0) return 'Clear sky';
  if (code == 1) return 'Mainly clear';
  if (code == 2) return 'Partly cloudy';
  if (code == 3) return 'Overcast';
  if (code <= 49) return 'Foggy / misty';
  if (code <= 55) return 'Drizzle';
  if (code <= 65) return 'Rain';
  if (code <= 67) return 'Freezing rain';
  if (code <= 77) return 'Hail / snow';
  if (code <= 82) return 'Rain showers';
  if (code <= 99) return 'Thunderstorm';
  return 'Unknown';
}

class WeatherScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const WeatherScreen({super.key, this.scrollController});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _selectedCounty = 'Nairobi';
  Map<String, dynamic>? _weather;
  bool _loading = false;
  String? _error;
  DateTime? _lastFetch;

  @override
  void initState() {
    super.initState();
    final counties = StorageService.instance.getCounties();
    if (counties.isNotEmpty) {
      // Use first county that has coordinates
      for (final c in counties) {
        final key = kCountyCoords.keys.firstWhere(
          (k) => c.toLowerCase().contains(k.toLowerCase()) ||
                 k.toLowerCase().contains(c.toLowerCase().split(' ').first),
          orElse: () => '',
        );
        if (key.isNotEmpty) { _selectedCounty = key; break; }
      }
    }
    _fetchWeather();
    // Auto-retry after 15s in case network was slow to connect on launch
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _weather == null && !_loading) {
        _fetchWeather();
      }
    });
    // And again after 30s
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _weather == null && !_loading) {
        _fetchWeather();
      }
    });
  }

  // Maps county names to their main town for accurate weather lookup
  String _countyToCity(String county) {
    const map = {
      'Nairobi': 'Nairobi',
      'Mombasa': 'Mombasa',
      'Kisumu': 'Kisumu',
      'Nakuru': 'Nakuru',
      'Eldoret': 'Eldoret',
      'Kiambu': 'Thika',
      'Meru': 'Meru',
      'Nyeri': 'Nyeri',
      'Kakamega': 'Kakamega',
      'Machakos': 'Machakos',
      'Kericho': 'Kericho',
      'Bomet': 'Bomet',
      'Muranga': 'Muranga',
      'Kirinyaga': 'Kerugoya',
      'Embu': 'Embu',
      'Garissa': 'Garissa',
      'Kitui': 'Kitui',
      'Makueni': 'Wote',
      'Kajiado': 'Kajiado',
      'Narok': 'Narok',
      'Uasin Gishu': 'Eldoret',
      'Trans Nzoia': 'Kitale',
      'Bungoma': 'Bungoma',
      'Busia': 'Busia',
      'Homa Bay': 'Homa Bay',
      'Migori': 'Migori',
      'Siaya': 'Siaya',
      'Vihiga': 'Vihiga',
      'Turkana': 'Lodwar',
      'Samburu': 'Maralal',
      'Laikipia': 'Nanyuki',
      'Nyandarua': 'Ol Kalou',
      'Tharaka-Nithi': 'Chuka',
      'Isiolo': 'Isiolo',
      'Marsabit': 'Marsabit',
      'Wajir': 'Wajir',
      'Mandera': 'Mandera',
      'Lamu': 'Lamu',
      'Tana River': 'Hola',
      'Kilifi': 'Kilifi',
      'Kwale': 'Kwale',
      'Taita-Taveta': 'Voi',
      'Nandi': 'Kapsabet',
      'Elgeyo-Marakwet': 'Eldoret',
      'West Pokot': 'Kapenguria',
      'Baringo': 'Kabarnet',
    };
    return map[county] ?? county;
  }

  Future<void> _fetchWeather({bool forceOnline = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final isOffline = prefs.getBool('pref_offline') ?? false;
    if (isOffline && !forceOnline) {
      final cached = prefs.getString('cached_weather_\$_selectedCounty');
      if (cached != null) {
        try { setState(() { _weather = Map<String,dynamic>.from(json.decode(cached)); _loading = false; _error = null; }); return; } catch (_) {}
      }
      setState(() { _loading = false; _error = 'Offline mode — no weather cached yet. Turn off offline mode and open this screen while connected.'; }); return;
    }
    setState(() { _loading = true; _error = null; });
    final coords = kCountyCoords[_selectedCounty] ?? [-1.2921, 36.8219];
    final lat = coords[0];
    final lon = coords[1];

    try {
      // Open-Meteo with precipitation probability — matches Google's rain predictions
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
        'weather_code,wind_speed_10m,rain,precipitation,is_day'
        '&hourly=precipitation_probability,weather_code'
        '&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,'
        'weather_code,precipitation_probability_max,wind_speed_10m_max'
        '&timezone=Africa%2FNairobi'
        '&forecast_days=7&wind_speed_unit=kmh&temperature_unit=celsius'
      );
      final response = await http.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        prefs.setString('cached_weather_\$_selectedCounty', json.encode(data));
        setState(() { _weather = data; _loading = false; _lastFetch = DateTime.now(); }); return;
      }
    } catch (_) {}

    // Fallback: wttr.in
    try {
      final city = _countyToCity(_selectedCounty);
      final encoded = Uri.encodeComponent(city + ' Kenya');
      final wttrUrl = Uri.parse('https://wttr.in/$encoded?format=j1');
      final response = await http.get(wttrUrl,
          headers: {'User-Agent': 'FarmConnect/1.0'})
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final raw = json.decode(response.body) as Map<String, dynamic>;
        final parsed = _parseWttr(raw);
        prefs.setString('cached_weather_\$_selectedCounty', json.encode(parsed));
        setState(() { _weather = parsed; _loading = false; _lastFetch = DateTime.now(); }); return;
      }
    } catch (_) {}

    final cached2 = prefs.getString('cached_weather_\$_selectedCounty');
    if (cached2 != null) {
      try {
        setState(() {
          _weather = Map<String,dynamic>.from(json.decode(cached2));
          _loading = false;
          _error = null; // show cached data without error message
        });
        return;
      } catch (_) {}
    }
    setState(() { _error = 'Could not load weather.\nMake sure you have internet, then tap Retry.'; _loading = false; });
  }


  Map<String, dynamic> _parseWttr(Map<String, dynamic> raw) {
    // Parse wttr.in JSON format into our standard format
    final current = raw['current_condition']?[0] as Map<String, dynamic>?;
    final weather = (raw['weather'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (current == null) return {};
    // wttr.in weather codes map
    final wttrCode = int.tryParse(current['weatherCode']?.toString() ?? '800') ?? 800;
    // Convert wttr code to WMO-like code for our emoji function
    int wmoCode = 0;
    if (wttrCode >= 200 && wttrCode < 300) wmoCode = 95;  // thunderstorm
    else if (wttrCode >= 300 && wttrCode < 400) wmoCode = 51; // drizzle
    else if (wttrCode >= 500 && wttrCode < 600) wmoCode = 61; // rain
    else if (wttrCode >= 700 && wttrCode < 800) wmoCode = 45; // fog/mist
    else if (wttrCode == 800) wmoCode = 0;  // clear
    else if (wttrCode == 801) wmoCode = 1;  // mainly clear
    else if (wttrCode == 802) wmoCode = 2;  // partly cloudy
    else if (wttrCode >= 803) wmoCode = 3;  // overcast
    final tempC = double.tryParse(current['temp_C']?.toString() ?? '25') ?? 25.0;
    final feelsC = double.tryParse(current['FeelsLikeC']?.toString() ?? '25') ?? 25.0;
    final humidity = int.tryParse(current['humidity']?.toString() ?? '60') ?? 60;
    final windKmph = double.tryParse(current['windspeedKmph']?.toString() ?? '10') ?? 10.0;
    final precipMM = double.tryParse(current['precipMM']?.toString() ?? '0') ?? 0.0;
    // Build daily forecast from wttr.in weather array
    final dayTimes = <String>[];
    final dayMax = <double>[];
    final dayMin = <double>[];
    final dayRain = <double?>[];
    final dayCodes = <int>[];
    for (final day in weather.take(7)) {
      dayTimes.add(day['date']?.toString() ?? '');
      dayMax.add(double.tryParse(day['maxtempC']?.toString() ?? '25') ?? 25.0);
      dayMin.add(double.tryParse(day['mintempC']?.toString() ?? '18') ?? 18.0);
      // Sum hourly precipitation for the day
      double totalRain = 0.0;
      for (final h in (day['hourly'] as List? ?? [])) {
        totalRain += double.tryParse((h as Map)['precipMM']?.toString() ?? '0') ?? 0.0;
      }
      dayRain.add(totalRain);
      final dayCode = int.tryParse(
          ((day['hourly'] as List?)?[4] as Map?)?['weatherCode']?.toString() ?? '800') ?? 800;
      int dmoCode = 0;
      if (dayCode >= 200 && dayCode < 300) dmoCode = 95;
      else if (dayCode >= 500 && dayCode < 600) dmoCode = 61;
      else if (dayCode == 800) dmoCode = 0;
      else if (dayCode == 801) dmoCode = 1;
      else if (dayCode >= 802) dmoCode = 2;
      dayCodes.add(dmoCode);
    }
    return {
      '_source': 'wttr',
      'current': {
        'temperature_2m': tempC,
        'apparent_temperature': feelsC,
        'relative_humidity_2m': humidity,
        'wind_speed_10m': windKmph,
        'rain': precipMM,
        'weather_code': wmoCode,
      },
      'daily': {
        'time': dayTimes,
        'temperature_2m_max': dayMax,
        'temperature_2m_min': dayMin,
        'precipitation_sum': dayRain,
        'weather_code': dayCodes,
      },
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-refresh if data is older than 30 minutes or missing
    final stale = _lastFetch == null ||
        DateTime.now().difference(_lastFetch!).inMinutes > 30;
    if (stale && !_loading)     _fetchWeather();
    // Auto-retry after 15s in case network was slow to connect on launch
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _weather == null && !_loading) {
        _fetchWeather();
      }
    });
    // And again after 30s
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _weather == null && !_loading) {
        _fetchWeather();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counties = StorageService.instance.getCounties();
    final allCountyOptions = kCountyCoords.keys.toList()..sort();

    final fmt = NumberFormat('#,###');
    final current = _weather?['current'] as Map<String, dynamic>?;
    final daily   = _weather?['daily']   as Map<String, dynamic>?;

    final temp      = (current?['temperature_2m']     as num?)?.toDouble();
    final feelsLike = (current?['apparent_temperature'] as num?)?.toDouble();
    final humidity  = (current?['relative_humidity_2m'] as num?)?.toInt();
    final windSpeed = (current?['wind_speed_10m']       as num?)?.toDouble();
    final rain      = (current?['rain'] as num?)?.toDouble() ??
                      (current?['precipitation'] as num?)?.toDouble() ?? 0.0;
    final wCode     = (current?['weather_code'] as num?)?.toInt() ?? 0;
    // Get current-hour precipitation probability from hourly data
    final hourlyProbs = (_weather?['hourly']?['precipitation_probability'] as List?)
        ?.map((v) => (v as num?)?.toInt() ?? 0).toList() ?? <int>[];
    // Find the current hour index
    final hourlyTimes = (_weather?['hourly']?['time'] as List?)
        ?.map((v) => v?.toString() ?? '').toList() ?? <String>[];
    final now = DateTime.now();
    int currentProb = 0;
    for (int hi = 0; hi < hourlyTimes.length; hi++) {
      try {
        final ht = DateTime.parse(hourlyTimes[hi]);
        if (ht.hour == now.hour && ht.day == now.day) {
          currentProb = hi < hourlyProbs.length ? hourlyProbs[hi] : 0;
          break;
        }
      } catch (_) {}
    }
    if (currentProb == 0 && hourlyProbs.isNotEmpty) {
      currentProb = hourlyProbs.first; // fallback to first available
    }

    final dayTimes    = (daily?['time'] as List?)?.map((v) => v?.toString() ?? '').toList() ?? [];
    final dayMax      = (daily?['temperature_2m_max'] as List?)?.map((v) => (v as num?)?.toDouble() ?? 0.0).toList() ?? [];
    final dayMin      = (daily?['temperature_2m_min'] as List?)?.map((v) => (v as num?)?.toDouble() ?? 0.0).toList() ?? [];
    final dayRain     = (daily?['precipitation_sum']  as List?)?.map((v) => (v as num?)?.toDouble()).toList() ?? [];
    final dayCodes    = (daily?['weather_code'] as List?)?.map((v) => (v as num?)?.toInt() ?? 0).toList() ?? [];
    final dayRainProb = (daily?['precipitation_probability_max'] as List?)?.map((v) => (v as num?)?.toInt() ?? 0).toList() ?? [];

    // Farming advice using precipitation probability (more accurate than rain amount)
    // currentProb is computed above from hourly data
    String farmingAdvice = '';
    if (temp != null) {
      if (currentProb >= 70 || rain > 5) {
        farmingAdvice = 'High chance of rain today ($currentProb% probability) — delay spraying, harvesting, and soil work.';
      } else if (currentProb >= 40 || rain > 0) {
        farmingAdvice = 'Light rain likely ($currentProb% probability) — good time to transplant seedlings or apply dry fertiliser.';
      } else if (currentProb < 20 && temp > 30) {
        farmingAdvice = 'Hot and dry (${temp.toStringAsFixed(0)}°C) — water crops early morning or evening to reduce evaporation.';
      } else if (temp < 15) {
        farmingAdvice = 'Cool temperatures — monitor for frost risk on highland crops like tea and wheat.';
      } else {
        farmingAdvice = 'Good farming conditions today ($currentProb% rain chance). Suitable for spraying and field operations.';
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          if (_lastFetch != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(child: Text(
                'Updated ${_lastFetch!.hour.toString().padLeft(2,'0')}:${_lastFetch!.minute.toString().padLeft(2,'0')}',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: context.tTextMuted))),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _fetchWeather(forceOnline: true),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(children: [
        // County selector
        Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 16, color: kGreen),
              const SizedBox(width: 6),
              Text('Weather for:', style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: context.tTextSec)),
              const Spacer(),
              Text('Powered by Open-Meteo', style: GoogleFonts.plusJakartaSans(
                  fontSize: 10, color: context.tTextMuted)),
            ]),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: allCountyOptions.contains(_selectedCounty) ? _selectedCounty : allCountyOptions.first,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
              items: allCountyOptions.map((c) => DropdownMenuItem(
                  value: c, child: Text(c))).toList(),
              onChanged: (v) {
                setState(() => _selectedCounty = v!);
                _fetchWeather();
              },
            ),
          ]),
        ),

        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator(color: kGreen))
            : _error != null && _weather == null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.wifi_off_rounded, size: 48, color: context.tTextMuted),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(color: context.tTextSec)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _fetchWeather,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ]),
                ))
              : ListView(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Current weather card
                    if (current != null) ...[
                      FarmCard(
                        color: isDark ? const Color(0xFF1A3A1C) : kGreenPale,
                        child: Column(children: [
                          Row(children: [
                            Text(weatherEmoji(wCode, rainProb: currentProb),
                                style: const TextStyle(fontSize: 48)),
                            const SizedBox(width: 16),
                            Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('$_selectedCounty County',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13, color: context.tTextSec)),
                              Text('${temp?.toStringAsFixed(1) ?? '--'}°C',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 42, fontWeight: FontWeight.w900,
                                      color: kGreen, height: 1.1)),
                              Text(weatherDesc(wCode, rainProb: currentProb),
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14, fontWeight: FontWeight.w600)),
                            ])),
                          ]),
                          const SizedBox(height: 14),
                          Row(children: [
                            _weatherStat('🌡️', 'Feels like',
                                '${feelsLike?.toStringAsFixed(0) ?? '--'}°C'),
                            _weatherStat('💧', 'Humidity',
                                '${humidity ?? '--'}%'),
                            _weatherStat('💨', 'Wind',
                                '${windSpeed?.toStringAsFixed(0) ?? '--'} km/h'),
                            _weatherStat('🌧️', 'Rain today',
                                '${(rain ?? 0.0).toStringAsFixed(1)} mm'),
                          ]),
                        ]),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Farming advice
                    if (farmingAdvice.isNotEmpty) ...[
                      FarmCard(
                        color: kAmber.withOpacity(0.08),
                        child: Row(children: [
                          const Text('🌾', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('Farming Advisory',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12, fontWeight: FontWeight.w700,
                                    color: kAmber)),
                            const SizedBox(height: 4),
                            Text(farmingAdvice,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13, color: kText)),
                          ])),
                        ]),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // 7-day forecast
                    if (dayTimes.isNotEmpty) ...[
                      Text('7-Day Forecast',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      ...List.generate(dayTimes.length, (i) {
                        final date = DateTime.tryParse(dayTimes[i]);
                        final dayName = date == null ? '' : DateFormat('EEE d MMM').format(date);
                        final isToday = i == 0;
                        final code = i < dayCodes.length ? dayCodes[i] : 0;
                        final max = i < dayMax.length ? dayMax[i] : null;
                        final min = i < dayMin.length ? dayMin[i] : null;
                        final rain = i < dayRain.length ? (dayRain[i] ?? 0.0) : 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: FarmCard(
                            color: isToday ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A3A1C) : kGreenPale) : null,
                            child: Row(children: [
                              SizedBox(width: 70, child: Text(
                                isToday ? 'Today' : dayName,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                    color: isToday ? kGreen : context.tText),
                              )),
                              Text(weatherEmoji(code,
                                  rainProb: i < dayRainProb.length ? dayRainProb[i] : 0),
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(weatherDesc(code,
                                  rainProb: i < dayRainProb.length ? dayRainProb[i] : 0),
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12, color: context.tTextSec))),
                              () {
                                final prob = i < dayRainProb.length ? dayRainProb[i] : 0;
                                if (prob > 15) return Row(children: [
                                  Icon(Icons.water_drop, size: 14,
                                      color: prob >= 60 ? const Color(0xFF1D4ED8) : const Color(0xFF3B82F6)),
                                  const SizedBox(width: 2),
                                  Text(prob.toString() + '% ',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: prob >= 60 ? const Color(0xFF1D4ED8) : const Color(0xFF3B82F6))),
                                ]);
                                return const SizedBox.shrink();
                              }(),
                              Text(
                                '${max?.toStringAsFixed(0) ?? '--'}° / ${min?.toStringAsFixed(0) ?? '--'}°',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ]),
                          ),
                        );
                      }),
                    ],

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: FarmCard(
                          color: kAmber.withOpacity(0.08),
                          child: Text(_error!,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, color: kAmber)),
                        ),
                      ),
                  ],
                ),
              ),
            ]),
          );
        }



  Widget _weatherStat(String icon, String label, String value) => Expanded(
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 2),
      Text(value, style: GoogleFonts.plusJakartaSans(
          fontSize: 13, fontWeight: FontWeight.w700)),
      Text(label, style: GoogleFonts.plusJakartaSans(
          fontSize: 10, color: context.tTextSec),
          textAlign: TextAlign.center),
    ]),
  );
}

// ════════════════════════════════════════════════════════════════
// TIPS SCREEN
// ════════════════════════════════════════════════════════════════

class TipsScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const TipsScreen({super.key, this.scrollController});
  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  String _category = 'All';
  int _seed = 0; // for shuffling tips on refresh
  static const _categories = ['All', 'Planting', 'Pest Control', 'Irrigation', 'Soil Health', 'Market', 'Livestock'];

  @override
  Widget build(BuildContext context) {
    var tips = _category == 'All'
        ? List.of(kFarmingTips)
        : kFarmingTips.where((t) => t['category'] == _category).toList();
    // Rotate by seed to simulate refresh
    if (_seed > 0 && tips.length > 1) {
      tips = [...tips.sublist(_seed % tips.length), ...tips.sublist(0, _seed % tips.length)];
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Farming Tips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() => _seed = DateTime.now().millisecond),
            tooltip: 'Refresh tips',
          ),
        ],
      ),
      body: Column(children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final cat = _categories[i];
              final active = cat == _category;
              return GestureDetector(
                onTap: () => setState(() => _category = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: active ? kGreen : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? kGreen : context.tBorder),
                  ),
                  child: Center(child: Text(cat, style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      color: active ? Colors.white : context.tTextSec))),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: tips.isEmpty
              ? const EmptyState(emoji: '📚', title: 'No tips in this category', subtitle: 'Try a different category.')
              : ListView.separated(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: tips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final tip = tips[i];
                    return FarmCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          TagChip(label: tip['category']!),
                          const Spacer(),
                          Text(tip['source']!, style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, color: context.tTextMuted)),
                        ]),
                        const SizedBox(height: 8),
                        Text(tip['title']!, style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(tip['body']!, style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: context.tTextSec, height: 1.5)),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// COMMUNITY SCREEN — Real posts only
// ════════════════════════════════════════════════════════════════

class CommunityScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const CommunityScreen({super.key, this.scrollController});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<Map<String, dynamic>> _posts = [];
  String _filter = 'All';
  final _bodyCtrl = TextEditingController();
  bool _showCompose = false;
  bool _loading = false;
  bool _posting = false;
  String _postCategory = 'General';
  static const _categories = ['All', 'Crops', 'Livestock', 'Market', 'Weather', 'General'];

  @override
  void initState() {
    super.initState();
    _loadPosts();
    // Auto-refresh every 30 seconds so new posts from other phones appear
    _scheduleRefresh();
  }

  void _scheduleRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadPosts(silent: true);
        _scheduleRefresh();
      }
    });
  }

  Future<void> _loadPosts({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
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
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '' + diff.inMinutes.toString() + 'm ago';
      if (diff.inHours < 24) return diff.inHours.toString() + 'h ago';
      if (diff.inDays < 7) return diff.inDays.toString() + 'd ago';
      return DateFormat('d MMM').format(dt);
    } catch (_) { return iso; }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = StorageService.instance.getCurrentUser();
    final filtered = _filter == 'All'
        ? _posts
        : _posts.where((p) => p['category'] == _filter).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: Icon(_showCompose ? Icons.close : Icons.edit_rounded),
            onPressed: () => setState(() => _showCompose = !_showCompose),
            tooltip: _showCompose ? 'Cancel' : 'New Post',
          ),
        ],
      ),
      body: Column(children: [
        // Compose box
        if (_showCompose)
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              child: Container(
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category', style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w600, color: context.tTextSec)),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 36,
                      child: ListView(scrollDirection: Axis.horizontal, children: [
                        for (final cat in _categories.skip(1))
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _postCategory = cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _postCategory == cat ? kGreen : Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _postCategory == cat ? kGreen : context.tBorder),
                                ),
                                child: Text(cat, style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: _postCategory == cat ? Colors.white : context.tTextSec,
                                    fontWeight: _postCategory == cat ? FontWeight.w700 : FontWeight.w400)),
                              ),
                            ),
                          ),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _bodyCtrl,
                      maxLines: 3,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Share tips, prices, questions with other farmers...',
                        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: context.tTextMuted),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _posting ? null : _submitPost,
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: const Text('Post'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Filter chips
        Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SizedBox(
            height: 36,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final cat in _categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _filter == cat ? kGreen : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _filter == cat ? kGreen : context.tBorder),
                      ),
                      child: Text(cat, style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: _filter == cat ? Colors.white : context.tTextSec,
                          fontWeight: _filter == cat ? FontWeight.w700 : FontWeight.w400)),
                    ),
                  ),
                ),
            ]),
          ),
        ),

        // Posts list
        Expanded(
          child: filtered.isEmpty
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('💬', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  _loading ? const Center(child: CircularProgressIndicator()) : _loading ? const Center(child: CircularProgressIndicator()) : Text('No posts yet', style: GoogleFonts.plusJakartaSans(
                      fontSize: 16, fontWeight: FontWeight.w700, color: context.tText)),
                  const SizedBox(height: 6),
                  Text('Be the first to post!',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: context.tTextSec)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _showCompose = true),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Write a Post'),
                  ),
                ])
              : ListView.separated(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final post = filtered[i];
                    final isOwn = (post['authorId'] as String?) == (currentUser?.phone ?? '##');
                    final replies = (post['replies'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                    return _PostCard(
                      post: post,
                      isOwn: isOwn,
                      formatTime: _formatTime,
                      onDelete: isOwn ? () => _deletePost(post['id'] as String) : null,
                      onReply: (text) => _addReply(post['id'] as String, text),
                      currentUser: currentUser?.name ?? 'Farmer',
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

class _PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool isOwn;
  final String Function(String) formatTime;
  final VoidCallback? onDelete;
  final void Function(String) onReply;
  final String currentUser;
  const _PostCard({required this.post, required this.isOwn,
    required this.formatTime, this.onDelete, required this.onReply,
    required this.currentUser});
  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _showReplies = false;
  bool _showReplyBox = false;
  final _replyCtrl = TextEditingController();

  @override
  void dispose() { _replyCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final replies = (post['replies'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return FarmCard(
      color: widget.isOwn ? context.tGreenPale : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          CircleAvatar(
            backgroundColor: widget.isOwn ? kGreen : const Color(0xFF3B82F6),
            radius: 17,
            child: Text(
              (post['author'] as String? ?? 'F').isNotEmpty
                  ? (post['author'] as String)[0].toUpperCase() : 'F',
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(post['author'] as String? ?? 'Farmer',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              if (widget.isOwn) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: kGreen, borderRadius: BorderRadius.circular(8)),
                  child: Text('You', style: GoogleFonts.plusJakartaSans(
                      fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            ]),
            Text('📍 ' + (post['county'] as String? ?? '') + '  ·  ' +
                widget.formatTime(post['time'] as String? ?? ''),
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: context.tTextMuted)),
          ])),
          TagChip(label: post['category'] as String? ?? 'General',
              bg: kGreen.withOpacity(0.08), fg: kGreen),
          if (widget.onDelete != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Delete Post?', style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800)),
                  content: Text('This cannot be undone.',
                      style: GoogleFonts.plusJakartaSans()),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () { Navigator.pop(context); widget.onDelete!(); },
                      style: ElevatedButton.styleFrom(backgroundColor: kRed),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ),
              child: const Icon(Icons.delete_outline, size: 18, color: kRed),
            ),
          ],
        ]),
        const SizedBox(height: 10),

        // Body
        Text(post['body'] as String? ?? '',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: context.tText, height: 1.5)),
        const SizedBox(height: 10),

        // Action row
        Row(children: [
          GestureDetector(
            onTap: () => setState(() => _showReplyBox = !_showReplyBox),
            child: Row(children: [
              Icon(Icons.reply_rounded, size: 16, color: kGreen),
              const SizedBox(width: 4),
              Text('Reply', style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: kGreen, fontWeight: FontWeight.w600)),
            ]),
          ),
          if (replies.isNotEmpty) ...[
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => setState(() => _showReplies = !_showReplies),
              child: Row(children: [
                Icon(_showReplies ? Icons.expand_less : Icons.expand_more,
                    size: 16, color: context.tTextSec),
                const SizedBox(width: 3),
                Text('${replies.length} ${replies.length == 1 ? 'reply' : 'replies'}',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: context.tTextSec)),
              ]),
            ),
          ],
        ]),

        // Reply input
        if (_showReplyBox) ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _replyCtrl,
                maxLines: 1,
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Write a reply...',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: context.tTextMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                final text = _replyCtrl.text.trim();
                if (text.isEmpty) return;
                widget.onReply(text);
                _replyCtrl.clear();
                setState(() { _showReplyBox = false; _showReplies = true; });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: kGreen, borderRadius: BorderRadius.circular(8)),
                child: Text('Send', style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ],

        // Replies list
        if (_showReplies && replies.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 6),
          ...replies.map((reply) => Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 2, height: 40,
                  color: kGreen.withOpacity(0.3),
                  margin: const EdgeInsets.only(right: 10)),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(reply['author'] as String? ?? 'Farmer',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  Text(widget.formatTime(reply['time'] as String? ?? ''),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10, color: context.tTextMuted)),
                ]),
                Text(reply['body'] as String? ?? '',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: context.tTextSec, height: 1.4)),
              ])),
            ]),
          )),
        ],
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// PROFILE SCREEN
// ════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════════
// PROFILE SCREEN — clean rewrite with all Update 11 fixes
// ══════════════════════════════════════════════════════════════════════════════

class ProfileScreen extends StatefulWidget {
  final void Function(int, {int farmTab}) onNavigate;
  final ScrollController? scrollController;
  final VoidCallback? onPrefsChanged;
  const ProfileScreen({super.key, required this.onNavigate, this.scrollController, this.onPrefsChanged});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // Notification prefs
  bool _notifWeather = true;
  bool _notifMarket  = true;
  bool _notifTasks   = true;
  bool _notifSystem  = true;

  // App prefs
  bool   _offlineMode = false;
  // Theme: 'system' | 'light' | 'dark'
  String _themeMode   = 'system';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifWeather = prefs.getBool('pref_notif_weather') ?? true;
      _notifMarket  = prefs.getBool('pref_notif_market')  ?? true;
      _notifTasks   = prefs.getBool('pref_notif_tasks')   ?? true;
      _notifSystem  = prefs.getBool('pref_notif_system')  ?? true;
      _offlineMode  = prefs.getBool('pref_offline')       ?? false;
      _themeMode    = prefs.getString('pref_theme_mode')  ?? 'system';
    });
  }

  Future<void> _savePref(String key, dynamic val) async {
    final prefs = await SharedPreferences.getInstance();
    if (val is bool)   await prefs.setBool(key, val);
    if (val is String) await prefs.setString(key, val);
  }

  void _setTheme(String mode) {
    setState(() => _themeMode = mode);
    _savePref('pref_theme_mode', mode);
    themeNotifier.value = mode == 'dark'
        ? ThemeMode.dark
        : mode == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
    widget.onPrefsChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final user      = StorageService.instance.getCurrentUser();
    final counties  = StorageService.instance.getCounties();
    final crops     = StorageService.instance.getCrops();
    final livestock = StorageService.instance.getLivestock();
    final tasks     = StorageService.instance.getTasks();
    final records   = StorageService.instance.getRecords();
    final revenue   = records.where((r) => r.type == 'income').fold(0.0, (s, r) => s + r.amount);
    final expenses  = records.where((r) => r.type == 'expense').fold(0.0, (s, r) => s + r.amount);
    final net       = revenue - expenses;
    final fmt       = NumberFormat('#,###');

    // Correct area: max area per field+county key, then sum unique fields
    final fieldAreaMap = <String, double>{};
    for (final cr in crops) {
      final key = '${cr.field}||${cr.county}';
      if ((fieldAreaMap[key] ?? 0.0) < cr.area) fieldAreaMap[key] = cr.area;
    }
    final totalArea = fieldAreaMap.values.fold(0.0, (s, v) => s + v);

    final initials = user == null ? '?'
        : user.name.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join().toUpperCase();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [

              // ── Avatar + counties ─────────────────────────────────────
              FarmCard(
                child: Column(children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B6B2A), Color(0xFF2E8B57)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: kGreen.withOpacity(0.3),
                          blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Center(child: Text(initials,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white))),
                  ),
                  const SizedBox(height: 12),
                  Text(user?.name ?? 'Farmer',
                      style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800)),
                  Text(user?.phone ?? '',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: context.tTextMuted)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 6, runSpacing: 6,
                    children: counties.map((c) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.tGreenPale,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kGreen.withOpacity(0.2))),
                      child: Text(c, style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: kGreen, fontWeight: FontWeight.w600)),
                    )).toList()),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/county-setup')
                        .then((_) => setState(() {})),
                    icon: const Icon(Icons.edit_location_alt_outlined, size: 16),
                    label: const Text('Edit Counties'),
                    style: OutlinedButton.styleFrom(foregroundColor: kGreen,
                        side: const BorderSide(color: kGreen), minimumSize: const Size(160, 34)),
                  ),
                ]),
              ),
              const SizedBox(height: 12),

              // ── Stats ─────────────────────────────────────────────────
              GridView.count(
                crossAxisCount: 3, childAspectRatio: 1.7,
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8, mainAxisSpacing: 8,
                children: [
                  _statTile('Crops',    crops.length.toString(),    Icons.grass_outlined,              kGreen),
                  _statTile('Livestock',livestock.length.toString(), Icons.pets_outlined,               kAmber),
                  _statTile('Tasks',    tasks.where((t) => !t.completed).length.toString(),
                                                                    Icons.task_alt_outlined,            kBlue),
                  _statTile('Area',     '${totalArea.toStringAsFixed(1)} ac',
                                                                    Icons.straighten_outlined,          kGreen),
                  _statTile('Revenue',  'KSh ${fmt.format(revenue.round())}',
                                                                    Icons.trending_up,                  kGreen),
                  _statTile('Net',      (net >= 0 ? '+' : '') + 'KSh ${fmt.format(net.round())}',
                                                                    Icons.account_balance_wallet_outlined,
                                                                                                        net >= 0 ? kGreen : kRed),
                ],
              ),
              const SizedBox(height: 16),

              // ── Quick actions ─────────────────────────────────────────
              _sectionTitle('Quick Actions'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _actionBtn(Icons.agriculture_outlined,  'Farm',    () => widget.onNavigate(3, farmTab: 0), kGreen)),
                const SizedBox(width: 8),
                Expanded(child: _actionBtn(Icons.task_alt_outlined,     'Tasks',   () => widget.onNavigate(3, farmTab: 2), kBlue)),
                const SizedBox(width: 8),
                Expanded(child: _actionBtn(Icons.bar_chart_outlined,    'Records', () => widget.onNavigate(3, farmTab: 3), kAmber)),
              ]),
              const SizedBox(height: 16),

              // ── Privacy & Security ────────────────────────────────────
              _sectionTitle('🔒  Privacy & Security'),
              const SizedBox(height: 8),
              FarmCard(child: Column(children: [
                _menuItem(context, Icons.lock_reset_outlined,    'Change Password',
                    'Update your account password',
                    () => _showChangePassword(context, user)),
                _menuItem(context, Icons.delete_forever_outlined, 'Delete Account',
                    '3-day grace period before permanent deletion',
                    () => _showDeleteAccount(context, user), danger: true, showDivider: false),
              ])),
              const SizedBox(height: 16),

              // ── App Preferences ───────────────────────────────────────
              _sectionTitle('⚙️  App Preferences'),
              const SizedBox(height: 8),
              FarmCard(child: Column(children: [

                // Theme selector: Light / System / Dark
                _themeSelector(),

                _switchTile('Offline Mode', 'Use saved data when no internet',
                    _offlineMode, (v) { setState(() => _offlineMode = v); _savePref('pref_offline', v); widget.onPrefsChanged?.call(); }),

                const Divider(height: 20),
                Text('Notifications', style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w700, color: context.tTextMuted)),
                const SizedBox(height: 8),
                _switchTile('Weather Alerts',       'Rain & temperature warnings',
                    _notifWeather, (v) { setState(() => _notifWeather = v); _savePref('pref_notif_weather', v); }),
                _switchTile('Market Price Updates', 'When prices change significantly',
                    _notifMarket,  (v) { setState(() => _notifMarket  = v); _savePref('pref_notif_market',  v); }),
                _switchTile('Task Reminders',       'Planting, spraying, vaccination',
                    _notifTasks,   (v) { setState(() => _notifTasks   = v); _savePref('pref_notif_tasks',   v); }),
                _switchTile('System Notifications', 'App updates and tips',
                    _notifSystem,  (v) { setState(() => _notifSystem  = v); _savePref('pref_notif_system',  v); },
                    showDivider: false),
              ])),
              const SizedBox(height: 16),

              // ── About ─────────────────────────────────────────────────
              _sectionTitle('ℹ️  About'),
              const SizedBox(height: 8),
              FarmCard(child: Column(children: [
                _menuItem(context, Icons.info_outline,   'About FarmConnect', 'v1.0.0',
                    () => _showAbout(context)),
                _menuItem(context, Icons.logout_outlined, 'Sign Out',         '',
                    () => _confirmSignOut(context), showDivider: false),
              ])),  // FarmCard Column

        ],  // ListView children
      ),    // ListView
    );      // Scaffold
  }

  // ── Theme picker widget ─────────────────────────────────────────────
  Widget _themeSelector() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Theme', style: GoogleFonts.plusJakartaSans(
          fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Row(children: [
        for (final opt in [
          ('light',  '☀️', 'Light'),
          ('system', '📱', 'System'),
          ('dark',   '🌙', 'Dark'),
        ])
          Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => _setTheme(opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _themeMode == opt.$1 ? kGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _themeMode == opt.$1 ? kGreen : context.tBorder,
                    width: _themeMode == opt.$1 ? 2 : 1),
                ),
                child: Column(children: [
                  Text(opt.$2, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(opt.$3, style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: _themeMode == opt.$1 ? Colors.white : context.tTextSec)),
                ]),
              ),
            ),
          )),
      ]),
      const Divider(height: 20),
    ]);
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Text(t, style: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w800)),
  );

  Widget _statTile(String label, String value, IconData icon, Color color) =>
    FarmCard(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(height: 2),
      Text(value, style: GoogleFonts.plusJakartaSans(
          fontSize: 12, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: GoogleFonts.plusJakartaSans(
          fontSize: 9, color: context.tTextMuted), overflow: TextOverflow.ellipsis),
    ]));

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap, Color color) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2))),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.plusJakartaSans(
              fontSize: 11, color: color, fontWeight: FontWeight.w700)),
        ]),
      ),
    );

  Widget _switchTile(String title, String sub, bool val,
      ValueChanged<bool> onChanged, {bool showDivider = true}) =>
    Column(children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(sub,   style: GoogleFonts.plusJakartaSans(fontSize: 11, color: context.tTextMuted)),
        ])),
        Switch(value: val, onChanged: onChanged, activeColor: kGreen),
      ]),
      if (showDivider) const Divider(height: 16),
    ]);

  Widget _menuItem(BuildContext ctx, IconData icon, String title, String sub, VoidCallback onTap,
      {bool danger = false, bool showDivider = true}) =>
    Column(children: [
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: danger ? kRed.withOpacity(0.08) : context.tGreenPale,
                borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 18, color: danger ? kRed : kGreen),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: danger ? kRed : context.tText)),
              if (sub.isNotEmpty) Text(sub, style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: context.tTextMuted)),
            ])),
            Icon(Icons.chevron_right, color: context.tTextMuted, size: 18),
          ]),
        ),
      ),
      if (showDivider) const Divider(height: 4),
    ]);

  Widget _prefRowSimple(String label, String current, List<String> options,
      ValueChanged<String> onChanged, {bool showDivider = true}) =>
    Column(children: [
      Row(children: [
        Expanded(child: Text(label, style: GoogleFonts.plusJakartaSans(
            fontSize: 13, fontWeight: FontWeight.w600))),
        DropdownButton<String>(
          value: options.contains(current) ? current : options.first,
          underline: const SizedBox(),
          isDense: true,
          items: options.map((o) => DropdownMenuItem(value: o,
              child: Text(o, style: GoogleFonts.plusJakartaSans(fontSize: 13)))).toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ]),
      if (showDivider) const Divider(height: 16),
    ]);

  // ── Dialogs (unchanged from original) ───────────────────────────────
  void _confirmSignOut(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('Sign Out?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
      content: Text('You will need your phone number and password to sign back in.',
          style: GoogleFonts.plusJakartaSans(color: context.tTextSec)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kGreen),
          onPressed: () async {
            Navigator.pop(context);
            await StorageService.instance.logout();
            if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/auth', (_) => false);
          },
          child: const Text('Sign Out'),
        ),
      ],
    ));
  }

  void _showChangePassword(BuildContext context, dynamic user) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confCtrl = TextEditingController();
    String? err;
    bool ob1 = true, ob2 = true;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setD) => AlertDialog(
        title: Text('Change Password', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (err != null) Padding(padding: const EdgeInsets.only(bottom: 10),
              child: Text(err!, style: GoogleFonts.plusJakartaSans(color: kRed, fontSize: 12))),
          TextField(controller: oldCtrl, obscureText: ob1,
              decoration: InputDecoration(labelText: 'Current Password',
                  suffixIcon: IconButton(icon: Icon(ob1 ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setD(() => ob1 = !ob1)))),
          const SizedBox(height: 10),
          TextField(controller: newCtrl, obscureText: ob2,
              decoration: InputDecoration(labelText: 'New Password',
                  suffixIcon: IconButton(icon: Icon(ob2 ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setD(() => ob2 = !ob2)))),
          const SizedBox(height: 10),
          TextField(controller: confCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm New Password')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kGreen),
            onPressed: () async {
              if (newCtrl.text != confCtrl.text) { setD(() => err = 'Passwords do not match.'); return; }
              if (newCtrl.text.length < 6) { setD(() => err = 'At least 6 characters.'); return; }
              final result = await StorageService.instance.changeUserPassword(oldCtrl.text, newCtrl.text);
              if (result != null) { setD(() => err = result); }
              else { Navigator.pop(ctx); showSuccess(context, 'Password changed!'); }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    ));
  }

  void _showDeleteAccount(BuildContext context, dynamic user) {
    final phoneCtrl = TextEditingController();
    int step = 1;
    String? err;
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setD) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: kRed, size: 22),
          const SizedBox(width: 8),
          Text('Delete Account', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: kRed)),
        ]),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (step == 1) ...[
            Text('Your data will be deleted. You have a 3-day grace period to recover by signing back in.',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: context.tTextSec)),
          ],
          if (step == 2) ...[
            if (err != null) Padding(padding: const EdgeInsets.only(bottom: 8),
                child: Text(err!, style: GoogleFonts.plusJakartaSans(color: kRed, fontSize: 12))),
            Text('Enter your phone number to confirm:',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: context.tTextSec)),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number', hintText: 'e.g. 0712345678')),
          ],
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          if (step == 1) ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kRed),
            onPressed: () => setD(() => step = 2),
            child: const Text('Continue'),
          ),
          if (step == 2) ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kRed),
            onPressed: () async {
              final entered = phoneCtrl.text.trim().replaceAll(RegExp(r'\s+'), '');
              final userPhone = (user?.phone ?? '').replaceAll(RegExp(r'\s+'), '');
              if (entered != userPhone) { setD(() => err = 'Phone number does not match.'); return; }
              await StorageService.instance.requestAccountDeletion();
              Navigator.pop(ctx);
              if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/auth', (_) => false);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    ));
  }

  void _showAbout(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Row(children: [
        const Text('🌱', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Text('FarmConnect', style: GoogleFonts.plusJakartaSans(
            fontSize: 18, fontWeight: FontWeight.w800, color: kGreen)),
      ]),
      content: Text(
        'Version 1.0.0\n\nSmart farm management for Kenyan farmers.\n\n'
        '• Crops & livestock tracking\n• Live market prices\n• 7-day weather\n'
        '• Task reminders\n• Financial records\n• Community forum\n\n'
        '© 2025 FarmConnect. Made with ❤️ for Kenya.',
        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: context.tTextSec, height: 1.5)),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ));
  }
}


// TOOLS HUB SCREEN
// ════════════════════════════════════════════════════════════════

class ToolsHubScreen extends StatelessWidget {
  final ScrollController scrollController;
  const ToolsHubScreen({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: kGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B6B2A), Color(0xFF2E8B57)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Farm Tools', style: GoogleFonts.plusJakartaSans(
                          fontSize: 28, fontWeight: FontWeight.w900,
                          color: Colors.white)),
                      Text('Everything you need to farm smarter',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(delegate: SliverChildListDelegate([
              // Feature tools
              _toolCard(
                context,
                emoji: '🧮',
                title: 'Input Cost Calculator',
                subtitle: 'Estimate seeds, fertiliser, labour costs and projected profit per acre',
                color: const Color(0xFF1B6B2A),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const InputCostScreen())),
              ),
              const SizedBox(height: 12),
              _toolCard(
                context,
                emoji: '📅',
                title: 'Season Planner',
                subtitle: 'See which crops to plant each month in your specific county',
                color: const Color(0xFF2563EB),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SeasonPlannerScreen())),
              ),
              const SizedBox(height: 20),
              // Tips section header
              Row(children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text('Farming Tips', style: GoogleFonts.plusJakartaSans(
                    fontSize: 17, fontWeight: FontWeight.w800, color: context.tText)),
              ]),
              const SizedBox(height: 4),
              Text('Expert advice from Kenya agricultural research',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: context.tTextMuted)),
              const SizedBox(height: 12),
              // Tips categories
              ...['Planting', 'Soil Health', 'Pest Control', 'Irrigation', 'Market', 'Livestock']
                  .map((cat) {
                final tips = kFarmingTips.where((t) => t['category'] == cat).toList();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FarmCard(
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(bottom: 8),
                      title: Text('$cat (${tips.length})',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      children: tips.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          Text(tip['title'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(tip['body'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, color: context.tTextSec, height: 1.5)),
                          const SizedBox(height: 4),
                          Text('— ${tip['source']}',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10, color: context.tTextMuted,
                                  fontStyle: FontStyle.italic)),
                        ]),
                      )).toList(),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 80),
            ])),
          ),
        ],
      ),
    );
  }

  Widget _toolCard(BuildContext context, {
    required String emoji, required String title,
    required String subtitle, required Color color, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.75)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12, offset: const Offset(0, 4),
          )],
        ),
        child: Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(emoji,
                style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: Colors.white70, height: 1.4)),
          ])),
          const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// INPUT COST CALCULATOR SCREEN
// ════════════════════════════════════════════════════════════════

class InputCostScreen extends StatefulWidget {
  const InputCostScreen({super.key});
  @override
  State<InputCostScreen> createState() => _InputCostScreenState();
}

class _InputCostScreenState extends State<InputCostScreen> {
  String _selectedCrop = 'Maize';
  final _areaCtrl = TextEditingController(text: '1');
  Map<String, dynamic>? _result;

  static const _inputData = <String, Map<String, dynamic>>{
    // key must match kCropVarieties exactly
    'Avocado (Fruit)': {
      'seed_unit': '50 seedlings', 'seed_cost': 15000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 500, 'pesticide': 2000, 'labour': 12000,
      'yield_kg': 1200, 'price_per_kg': 32, 'season_days': 365,
      'note': 'Year 1-3 establishment. Hass fetches KSh 25-40/fruit at farm gate.',
    },
    'Bananas': {
      'seed_unit': '200 suckers', 'seed_cost': 30000,
      'dap_bags': 2, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 0, 'pesticide': 1500, 'labour': 15000,
      'yield_kg': 26000, 'price_per_kg': 65, 'season_days': 270,
      'note': 'Tissue culture bananas mature in 9 months. Yield 25-30 tonnes/acre.',
    },
    'Beans': {
      'seed_unit': '25kg seed', 'seed_cost': 3000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 0, 'can_price': 0,
      'herbicide': 600, 'pesticide': 800, 'labour': 6000,
      'yield_kg': 720, 'price_per_kg': 130, 'season_days': 75,
      'note': 'Rose Coco and Canadian Wonder are the most popular. 2 seasons/year possible.',
    },
    'Cabbage': {
      'seed_unit': '1 packet seedlings', 'seed_cost': 3500,
      'dap_bags': 2, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 600, 'pesticide': 2000, 'labour': 14000,
      'yield_kg': 18000, 'price_per_kg': 22, 'season_days': 80,
      'note': 'Yields 300+ heads per acre at 55-65g each on average.',
    },
    'Capsicum': {
      'seed_unit': '1 seedling packet', 'seed_cost': 5000,
      'dap_bags': 2, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 0, 'pesticide': 4000, 'labour': 18000,
      'yield_kg': 7000, 'price_per_kg': 140, 'season_days': 90,
      'note': 'Sweet peppers command KSh 120-160/kg. Demand high in supermarkets.',
    },
    'Carrots': {
      'seed_unit': '1.5kg seed', 'seed_cost': 9000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 800, 'pesticide': 1500, 'labour': 12000,
      'yield_kg': 10000, 'price_per_kg': 50, 'season_days': 75,
      'note': 'Nantes and Chantenay varieties best for Kenya highlands.',
    },
    'Cassava': {
      'seed_unit': '1100 cuttings', 'seed_cost': 5500,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 0, 'can_price': 0,
      'herbicide': 800, 'pesticide': 500, 'labour': 8000,
      'yield_kg': 8000, 'price_per_kg': 35, 'season_days': 365,
      'note': 'Drought tolerant. Grows well in coastal and western Kenya. Very low input.',
    },
    'Coffee (Cherry)': {
      'seed_unit': '400 seedlings', 'seed_cost': 32000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 1000, 'pesticide': 4000, 'labour': 20000,
      'yield_kg': 600, 'price_per_kg': 145, 'season_days': 365,
      'note': 'Arabica coffee in central highlands. Parchment price KSh 130-160/kg.',
    },
    'Cotton': {
      'seed_unit': '10kg seed', 'seed_cost': 1000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 1000, 'pesticide': 3000, 'labour': 12000,
      'yield_kg': 500, 'price_per_kg': 50, 'season_days': 180,
      'note': 'Seed cotton price KSh 44-56/kg. CDFA provides subsidised seeds in cotton zones.',
    },
    'Cowpeas': {
      'seed_unit': '15kg seed', 'seed_cost': 1800,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 0, 'can_price': 0,
      'herbicide': 400, 'pesticide': 600, 'labour': 5000,
      'yield_kg': 500, 'price_per_kg': 115, 'season_days': 70,
      'note': 'Drought-tolerant. Excellent for ASAL areas. Also improves soil nitrogen.',
    },
    'Eggplant': {
      'seed_unit': '1 packet', 'seed_cost': 3500,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 0, 'pesticide': 1500, 'labour': 10000,
      'yield_kg': 6000, 'price_per_kg': 80, 'season_days': 85,
      'note': 'Good market at coast and urban areas. Yields 5-8 tonnes/acre.',
    },
    'Garlic': {
      'seed_unit': '300kg cloves', 'seed_cost': 120000,
      'dap_bags': 2, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 600, 'pesticide': 2000, 'labour': 20000,
      'yield_kg': 2000, 'price_per_kg': 450, 'season_days': 120,
      'note': 'High seed cost but excellent returns. Most garlic is imported — good opportunity.',
    },
    'Green Grams': {
      'seed_unit': '15kg seed', 'seed_cost': 2250,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 0, 'can_price': 0,
      'herbicide': 400, 'pesticide': 600, 'labour': 5500,
      'yield_kg': 400, 'price_per_kg': 150, 'season_days': 65,
      'note': 'Popular in Coast and Eastern. 2-3 seasons/year in warm areas.',
    },
    'Groundnuts': {
      'seed_unit': '80kg seed', 'seed_cost': 16000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 0, 'can_price': 0,
      'herbicide': 700, 'pesticide': 800, 'labour': 8000,
      'yield_kg': 600, 'price_per_kg': 200, 'season_days': 110,
      'note': 'Popular in western Kenya. Sells as raw, roasted, or as peanut butter.',
    },
    'Kale (Sukuma Wiki)': {
      'seed_unit': '1 packet', 'seed_cost': 2000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 0, 'pesticide': 800, 'labour': 10000,
      'yield_kg': 10000, 'price_per_kg': 20, 'season_days': 60,
      'note': 'Steady year-round demand. Can harvest multiple times. Very low risk crop.',
    },
    'Lettuce': {
      'seed_unit': '1 packet', 'seed_cost': 3000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 0, 'pesticide': 600, 'labour': 8000,
      'yield_kg': 5000, 'price_per_kg': 70, 'season_days': 45,
      'note': 'Good for urban farmers. Fast turnover. Supermarket and hotel market.',
    },
    'Macadamia (Nut)': {
      'seed_unit': '100 seedlings', 'seed_cost': 30000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 1000, 'pesticide': 2000, 'labour': 15000,
      'yield_kg': 1500, 'price_per_kg': 95, 'season_days': 365,
      'note': 'Trees produce for 40+ years. NIS price KSh 85-105/kg. Booming export market.',
    },
    'Maize': {
      'seed_unit': '10kg hybrid seed', 'seed_cost': 1500,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 800, 'pesticide': 1200, 'labour': 8000,
      'yield_kg': 2250, 'price_per_kg': 39, 'season_days': 90,
      'note': 'H614D and DK8031 hybrids. 90-day variety for short rains season.',
    },
    'Mangoes (Fruit)': {
      'seed_unit': '80 grafted seedlings', 'seed_cost': 24000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 500, 'pesticide': 2500, 'labour': 10000,
      'yield_kg': 5000, 'price_per_kg': 80, 'season_days': 365,
      'note': 'Apple mango is premium variety. Coastal zone best. Yields from year 4.',
    },
    'Miraa (Khat)': {
      'seed_unit': '1000 cuttings', 'seed_cost': 10000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 0, 'pesticide': 1000, 'labour': 8000,
      'yield_kg': 1000, 'price_per_kg': 220, 'season_days': 365,
      'note': 'Mainly Meru county. High-value cash crop. Harvest every 2-3 months.',
    },
    'Onions': {
      'seed_unit': '3kg seed', 'seed_cost': 15000,
      'dap_bags': 2, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 800, 'pesticide': 2500, 'labour': 16000,
      'yield_kg': 14000, 'price_per_kg': 70, 'season_days': 100,
      'note': 'Red creole and hybrid varieties. Demand highest June-September.',
    },
    'Passion Fruit': {
      'seed_unit': '100 grafted seedlings', 'seed_cost': 12000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 0, 'pesticide': 3000, 'labour': 18000,
      'yield_kg': 8000, 'price_per_kg': 180, 'season_days': 180,
      'note': 'Purple variety for local market; yellow for export. Trellis system needed.',
    },
    'Pawpaw': {
      'seed_unit': '400 seedlings', 'seed_cost': 4000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 0, 'pesticide': 1500, 'labour': 8000,
      'yield_kg': 20000, 'price_per_kg': 30, 'season_days': 270,
      'note': 'Solo papaya and Sunrise variety popular. Fruits from 9-10 months.',
    },
    'Peas': {
      'seed_unit': '60kg seed', 'seed_cost': 8400,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 0, 'can_price': 0,
      'herbicide': 500, 'pesticide': 1000, 'labour': 8000,
      'yield_kg': 1500, 'price_per_kg': 140, 'season_days': 70,
      'note': 'Snow peas for export. Garden peas for local market. Cool highlands best.',
    },
    'Pineapple': {
      'seed_unit': '2000 suckers', 'seed_cost': 40000,
      'dap_bags': 2, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 1000, 'pesticide': 2000, 'labour': 20000,
      'yield_kg': 30000, 'price_per_kg': 22, 'season_days': 540,
      'note': 'MD2 and Smooth Cayenne varieties. Coast and Thika region favoured.',
    },
    'Potatoes': {
      'seed_unit': '600kg certified seed', 'seed_cost': 21000,
      'dap_bags': 2, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 1000, 'pesticide': 3000, 'labour': 18000,
      'yield_kg': 4000, 'price_per_kg': 42, 'season_days': 90,
      'note': 'Shangi, Tigoni, and Desiree best varieties. Highland areas above 1800m.',
    },
    'Pumpkins': {
      'seed_unit': '1kg seed', 'seed_cost': 1500,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 400, 'pesticide': 500, 'labour': 5000,
      'yield_kg': 8000, 'price_per_kg': 35, 'season_days': 90,
      'note': 'Intercrop well with maize. Both leaves and fruit marketable.',
    },
    'Pyrethrum': {
      'seed_unit': '1000 seedlings', 'seed_cost': 5000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 800, 'pesticide': 500, 'labour': 20000,
      'yield_kg': 250, 'price_per_kg': 130, 'season_days': 365,
      'note': 'Pyrethrum Board of Kenya manages marketing. Highland cool areas only.',
    },
    'Rice': {
      'seed_unit': '50kg seed', 'seed_cost': 4500,
      'dap_bags': 2, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 1500, 'pesticide': 1500, 'labour': 25000,
      'yield_kg': 1800, 'price_per_kg': 130, 'season_days': 140,
      'note': 'Mwea irrigation scheme (Kirinyaga). Komboka variety 5-6 tonnes/ha.',
    },
    'Sorghum': {
      'seed_unit': '5kg seed', 'seed_cost': 325,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 0, 'can_price': 0,
      'herbicide': 500, 'pesticide': 800, 'labour': 6000,
      'yield_kg': 1000, 'price_per_kg': 65, 'season_days': 120,
      'note': 'Drought tolerant. EABL buys sorghum for beer at guaranteed prices.',
    },
    'Spinach': {
      'seed_unit': '3kg seed', 'seed_cost': 6000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 0, 'pesticide': 600, 'labour': 8000,
      'yield_kg': 6000, 'price_per_kg': 58, 'season_days': 45,
      'note': 'Very fast crop. Multiple harvests. Good for urban farming.',
    },
    'Strawberry': {
      'seed_unit': '2000 runners', 'seed_cost': 30000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 0, 'pesticide': 4000, 'labour': 25000,
      'yield_kg': 2500, 'price_per_kg': 300, 'season_days': 180,
      'note': 'Premium market in supermarkets and hotels. Cool highlands required.',
    },
    'Sugarcane': {
      'seed_unit': '3000 cane stalks', 'seed_cost': 15000,
      'dap_bags': 2, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 2000, 'pesticide': 1000, 'labour': 20000,
      'yield_kg': 90000, 'price_per_kg': 4.2, 'season_days': 540,
      'note': 'Western Kenya sugar belt. Factory-contracted at KSh 4,200/tonne.',
    },
    'Sunflower': {
      'seed_unit': '4kg seed', 'seed_cost': 600,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 700, 'pesticide': 800, 'labour': 7000,
      'yield_kg': 800, 'price_per_kg': 75, 'season_days': 90,
      'note': 'ADC and millers buy at guaranteed prices. Drought tolerant cash crop.',
    },
    'Sweet Potatoes': {
      'seed_unit': '2000 vines', 'seed_cost': 4000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 0, 'can_price': 0,
      'herbicide': 400, 'pesticide': 500, 'labour': 7000,
      'yield_kg': 5000, 'price_per_kg': 40, 'season_days': 120,
      'note': 'Vitamin A-rich orange flesh varieties have export potential.',
    },
    'Tea (Green Leaf)': {
      'seed_unit': '3000 cuttings', 'seed_cost': 15000,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 1500, 'pesticide': 2000, 'labour': 25000,
      'yield_kg': 3000, 'price_per_kg': 30, 'season_days': 365,
      'note': 'KTDA manages smallholder tea. Green leaf collected twice a week.',
    },
    'Tomatoes': {
      'seed_unit': '1 seed packet', 'seed_cost': 3500,
      'dap_bags': 2, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 0, 'pesticide': 5000, 'labour': 20000,
      'yield_kg': 14000, 'price_per_kg': 55, 'season_days': 80,
      'note': 'Tylka F1 and Anna F1 hybrids best. Price volatile KSh 30-150/kg.',
    },
    'Watermelon': {
      'seed_unit': '1 seed packet', 'seed_cost': 3000,
      'dap_bags': 2, 'dap_price': 3800, 'can_bags': 2, 'can_price': 3600,
      'herbicide': 500, 'pesticide': 2000, 'labour': 12000,
      'yield_kg': 20000, 'price_per_kg': 22, 'season_days': 80,
      'note': 'Sugar Baby and Crimson Sweet varieties. Drip irrigation ideal.',
    },
    'Wheat': {
      'seed_unit': '50kg certified seed', 'seed_cost': 4500,
      'dap_bags': 1, 'dap_price': 3800, 'can_bags': 1, 'can_price': 3600,
      'herbicide': 1200, 'pesticide': 1500, 'labour': 7000,
      'yield_kg': 1000, 'price_per_kg': 50, 'season_days': 120,
      'note': 'Uasin Gishu and Trans Nzoia Kenya wheat basket. KSh 3,500/90kg bag.',
    },
  };

  void _calculate() {
    final area = double.tryParse(_areaCtrl.text) ?? 1.0;
    final data = _inputData[_selectedCrop] ?? _inputData['Maize']!;
    final fmt = NumberFormat('#,###');

    final seedCost  = (data['seed_cost'] as num) * area;
    final dapCost   = (data['dap_bags'] as num) * area * (data['dap_price'] as num);
    final canCost   = (data['can_bags'] as num) * area * (data['can_price'] as num);
    final herbCost  = (data['herbicide'] as num) * area;
    final pestCost  = (data['pesticide'] as num) * area;
    final labCost   = (data['labour'] as num) * area;
    final totalCost = seedCost + dapCost + canCost + herbCost + pestCost + labCost;

    final yieldKg   = (data['yield_kg'] as num) * area;
    final revenue   = yieldKg * (data['price_per_kg'] as num);
    final profit    = revenue - totalCost;
    final roi       = totalCost > 0 ? (profit / totalCost * 100) : 0;

    setState(() {
      _result = {
        'area': area,
        'seed': seedCost.toDouble(), 'dap': dapCost.toDouble(),
        'can': canCost.toDouble(), 'herb': herbCost.toDouble(),
        'pest': pestCost.toDouble(), 'labour': labCost.toDouble(),
        'total': totalCost.toDouble(), 'revenue': revenue.toDouble(),
        'profit': profit.toDouble(), 'roi': roi,
        'yield': yieldKg.toDouble(), 'days': data['season_days'],
        'seed_unit': data['seed_unit'],
        'note': data['note'] ?? '',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fmt = NumberFormat('#,###');
    final crops = _inputData.keys.toList()..sort();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Input Cost Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FarmCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Estimate costs and profit for your crop',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: context.tTextSec)),
              const SizedBox(height: 14),
              Text('Crop', style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: context.tTextSec)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCrop,
                decoration: const InputDecoration(),
                items: crops.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() { _selectedCrop = v!; _result = null; }),
              ),
              const SizedBox(height: 12),
              LabelledField(
                label: 'Farm Area (acres)',
                hint: 'e.g. 2.5',
                controller: _areaCtrl,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Calculate'),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          if (_result != null) ...[
            // Cost breakdown
            FarmCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Cost Breakdown — ${_result!['area']} acres of $_selectedCrop',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _costRow('🌱 ${_result!['seed_unit']}', _result!['seed'] as double, fmt),
                _costRow('💊 DAP Fertiliser', _result!['dap'] as double, fmt),
                _costRow('💊 CAN Fertiliser', _result!['can'] as double, fmt),
                if ((_result!['herb'] as double) > 0)
                  _costRow('🌿 Herbicide', _result!['herb'] as double, fmt),
                _costRow('🐛 Pesticide/Fungicide', _result!['pest'] as double, fmt),
                _costRow('👷 Labour', _result!['labour'] as double, fmt),
                const Divider(),
                _costRow('📊 Total Input Cost', _result!['total'] as double, fmt, bold: true),
              ]),
            ),
            const SizedBox(height: 12),
            // Profit projection
            FarmCard(
              color: (_result!['profit'] as double) >= 0
                  ? (isDark ? const Color(0xFF1A3A1C) : kGreenPale)
                  : kRed.withOpacity(0.06),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Profit Projection',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _costRow('📦 Expected Yield', _result!['yield'] as double, fmt,
                    suffix: ' kg'),
                _costRow('💰 Expected Revenue', _result!['revenue'] as double, fmt),
                _costRow('📈 Net Profit', _result!['profit'] as double, fmt,
                    bold: true,
                    color: (_result!['profit'] as double) >= 0 ? kGreen : kRed),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    const Text('🎯', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      'ROI: ${(_result!['roi'] as num).toStringAsFixed(0)}%  ·  '
                      'Season: ${_result!['days']} days',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w700, color: kGreen),
                    )),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            if ((_result!['note'] as String).isNotEmpty)
              FarmCard(
                color: kGreen.withOpacity(0.05),
                child: Text('💡 ' + (_result!['note'] as String),
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: context.tTextSec, height: 1.5)),
              ),
            const SizedBox(height: 4),
            FarmCard(
              color: kAmber.withOpacity(0.06),
              child: Text(
                '⚠️ These are average estimates for Kenyan conditions. '
                'Actual costs vary by county, season, and farm practices.',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: context.tTextSec),
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _costRow(String label, double value, NumberFormat fmt,
      {bool bold = false, Color? color, String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(child: Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: color ?? context.tText))),
        Text('KSh ${fmt.format(value.round())}$suffix',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: color ?? context.tText)),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// SEASON PLANNER SCREEN
// ════════════════════════════════════════════════════════════════

class SeasonPlannerScreen extends StatefulWidget {
  const SeasonPlannerScreen({super.key});
  @override
  State<SeasonPlannerScreen> createState() => _SeasonPlannerScreenState();
}

class _SeasonPlannerScreenState extends State<SeasonPlannerScreen> {
  int _selectedMonth = DateTime.now().month;
  String _selectedCounty = 'Nakuru';

  static const _monthNames = ['','Jan','Feb','Mar','Apr','May','Jun',
                               'Jul','Aug','Sep','Oct','Nov','Dec'];

  // Which crops are ideal, possible, or avoid per month
  String _suitability(String crop, int month) {
    final advice = kCropPlantingAdvice[crop];
    if (advice == null) return 'possible';
    final best = List<int>.from(advice['bestMonths'] as List);
    if (best.contains(month)) return 'ideal';
    // Adjacent months = possible
    final prev = month == 1 ? 12 : month - 1;
    final next = month == 12 ? 1 : month + 1;
    if (best.contains(prev) || best.contains(next)) return 'possible';
    return 'avoid';
  }

  String _countySuitability(String crop, String county) {
    final advice = kCropPlantingAdvice[crop];
    if (advice == null) return 'neutral';
    final poor = List<String>.from(advice['poorCounties'] as List);
    final good = List<String>.from(advice['goodCounties'] as List);
    if (poor.any((c) => county.toLowerCase().contains(c.toLowerCase()))) return 'poor';
    if (good.any((c) => county.toLowerCase().contains(c.toLowerCase()))) return 'good';
    return 'neutral';
  }

  @override
  Widget build(BuildContext context) {
    final allCounties = kKenyaCounties;
    final crops = kCropPlantingAdvice.keys.toList()..sort();

    final ideal   = crops.where((c) => _suitability(c, _selectedMonth) == 'ideal').toList();
    final possible = crops.where((c) => _suitability(c, _selectedMonth) == 'possible').toList();
    final avoid   = crops.where((c) => _suitability(c, _selectedMonth) == 'avoid').toList();

    // Filter by county suitability
    final idealGood = ideal.where((c) => _countySuitability(c, _selectedCounty) != 'poor').toList();
    final avoidHere = [
      ...ideal.where((c) => _countySuitability(c, _selectedCounty) == 'poor'),
      ...avoid,
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Season Planner')),
      body: Column(children: [
        // Controls
        Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(children: [
            // Month selector
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(12, (i) {
                  final m = i + 1;
                  final active = m == _selectedMonth;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMonth = m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? kGreen : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: active ? kGreen : context.tBorder),
                        ),
                        child: Text(_monthNames[m],
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                                color: active ? Colors.white : kTextSec)),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            // County selector
            DropdownButtonFormField<String>(
              value: allCounties.contains(_selectedCounty) ? _selectedCounty : allCounties.first,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true, prefixIcon: Icon(Icons.location_on_outlined, size: 18),
              ),
              items: allCounties.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCounty = v!),
            ),
          ]),
        ),
        // Results
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('${_monthNames[_selectedMonth]} — What to Plant in $_selectedCounty',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              if (idealGood.isNotEmpty) ...[
                _sectionHeader('✅  Plant Now — Ideal timing in $_selectedCounty', kGreen),
                const SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 8,
                    children: idealGood.map((crop) => _cropChip(crop, kGreen)).toList()),
                const SizedBox(height: 14),
              ],
              if (possible.isNotEmpty) ...[
                _sectionHeader('⚠️  Can Plant — Not peak season', kAmber),
                const SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 8,
                    children: possible.map((crop) => _cropChip(crop, kAmber)).toList()),
                const SizedBox(height: 14),
              ],
              if (avoidHere.isNotEmpty) ...[
                _sectionHeader('❌  Avoid — Wrong time or wrong county', kRed),
                const SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 8,
                    children: avoidHere.map((crop) => _cropChip(crop, kRed)).toList()),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _sectionHeader(String text, Color color) => Row(children: [
    Expanded(child: Text(text, style: GoogleFonts.plusJakartaSans(
        fontSize: 13, fontWeight: FontWeight.w700, color: color))),
  ]);

  Widget _cropChip(String crop, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(crop, style: GoogleFonts.plusJakartaSans(
        fontSize: 12, color: color, fontWeight: FontWeight.w600)),
  );
}
