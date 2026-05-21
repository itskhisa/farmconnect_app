import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';
import '../utils/storage.dart';
import '../data/farm_data.dart';

class CountySetupScreen extends StatefulWidget {
  const CountySetupScreen({super.key});
  @override
  State<CountySetupScreen> createState() => _CountySetupScreenState();
}

class _CountySetupScreenState extends State<CountySetupScreen> {
  final Set<String> _selected = {};
  final _searchCtrl = TextEditingController();
  List<String> _filtered = List.from(kKenyaCounties);

  @override
  void initState() {
    super.initState();
    _selected.addAll(StorageService.instance.getCounties());
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(kKenyaCounties)
          : kKenyaCounties.where((c) => c.toLowerCase().contains(q)).toList();
    });
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select at least one county'),
        backgroundColor: kRed,
      ));
      return;
    }
    await StorageService.instance.saveCounties(_selected.toList()..sort());
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(children: [
          // Header
          Container(
            color: kGreen,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('📍', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text('My Farm Counties',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ]),
              const SizedBox(height: 4),
              Text('Select all counties where you farm. You can change this later.',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: Colors.white.withOpacity(0.82))),
              const SizedBox(height: 12),
              // Search
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search county...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withOpacity(0.6), fontSize: 14),
                    prefixIcon: const Icon(Icons.search,
                        color: Colors.white, size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    fillColor: Colors.transparent, filled: true,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ]),
          ),

          // Selected count bar
          if (_selected.isNotEmpty)
            Container(
              color: kGreenPale,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                const Icon(Icons.check_circle, color: kGreen, size: 16),
                const SizedBox(width: 6),
                Text('${_selected.length} ${_selected.length == 1 ? 'county' : 'counties'} selected',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w600, color: kGreen)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _selected.clear()),
                  child: Text('Clear all',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: kRed)),
                ),
              ]),
            ),

          // County grid
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text('No counties found',
                    style: GoogleFonts.plusJakartaSans(color: kTextMuted)))
                : GridView.builder(
                    padding: const EdgeInsets.all(14),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 3.2,
                        crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) {
                      final county = _filtered[i];
                      final sel = _selected.contains(county);
                      return GestureDetector(
                        onTap: () => setState(() {
                          sel ? _selected.remove(county) : _selected.add(county);
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: sel ? kGreen : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: sel ? kGreen : Theme.of(context).dividerColor,
                                width: sel ? 1.5 : 1),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(children: [
                            Icon(sel ? Icons.check_circle : Icons.circle_outlined,
                                size: 16, color: sel ? Colors.white : kTextMuted),
                            const SizedBox(width: 6),
                            Expanded(child: Text(county,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                                    color: sel ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color))),
                          ]),
                        ),
                      );
                    },
                  ),
          ),

          // Save button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: kBorder)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(_selected.isEmpty
                    ? 'Select at least one county'
                    : 'Save & Continue  →'),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
