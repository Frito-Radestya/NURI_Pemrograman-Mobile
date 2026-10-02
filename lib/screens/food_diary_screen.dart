import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/akg_reference.dart';
import '../data/food_database.dart';
import '../models/child_profile.dart';
import '../models/food_entry.dart';
import '../services/auth_service.dart';
import '../services/child_service.dart';
import '../services/food_diary_service.dart';
import '../theme/app_colors.dart';
import '../widgets/nutrition_ring_widget.dart';

class FoodDiaryScreen extends StatefulWidget {
  const FoodDiaryScreen({super.key});

  @override
  State<FoodDiaryScreen> createState() => _FoodDiaryScreenState();
}

class _FoodDiaryScreenState extends State<FoodDiaryScreen>
    with SingleTickerProviderStateMixin {
  final _diaryService = FoodDiaryService();
  DateTime _selectedDate = DateTime.now();
  late TabController _tabController;

  static const _sessions = ['pagi', 'siang', 'malam', 'snack'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sessions.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _userId => AuthService().currentUser?.id ?? 'guest';

  List<ChildProfile> get _children => ChildService().getChildren(_userId);

  ChildProfile? get _primaryChild => _children.isEmpty ? null : _children.first;

  DailyNutritionSummary get _summary =>
      _diaryService.getSummary(userId: _userId, date: _selectedDate);

  void _goToPrevDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _goToNextDay() {
    if (!_isToday(_selectedDate)) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      });
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final today = DateTime.now();
    if (d.year == today.year && d.month == today.month && d.day == today.day) {
      return 'Hari Ini';
    }
    final yesterday = today.subtract(const Duration(days: 1));
    if (d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day) {
      return 'Kemarin';
    }
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _akgLabel(DailyNutritionSummary summary) {
    final child = _primaryChild!;
    final age = child.ageInMonths(_selectedDate);
    final target = AkgReference.forChild(
      ageMonths: age,
      isBoy: child.gender == 'L',
    );
    final pct = summary.percentOf(target);
    String traffic(double v) => v < 0.7 ? 'kurang' : 'cukup';
    return 'AKG anak $age bln: ${target.calories.toStringAsFixed(0)} kkal '
        '(${traffic(pct['calories']!)} ${(pct['calories']! * 100).toStringAsFixed(0)}%) · '
        'Protein ${traffic(pct['protein']!)}';
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Food Diary',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildHeader(summary)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: _buildTabBar(),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: _sessions
              .map(
                (session) => _SessionTab(
                  session: session,
                  userId: _userId,
                  date: _selectedDate,
                  diaryService: _diaryService,
                  onEntryChanged: () => setState(() {}),
                  onEdit: (entry) => _showFoodSheet(
                    session: entry.session,
                    existingEntry: entry,
                  ),
                ),
              )
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showFoodSheet(session: _sessions[_tabController.index]),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Tambah Makanan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader(DailyNutritionSummary summary) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1ED4C4), Color(0xFF00BFA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _goToPrevDay,
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    iconSize: 28,
                  ),
                  Text(
                    _formatDate(_selectedDate),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: _isToday(_selectedDate) ? null : _goToNextDay,
                    icon: Icon(
                      Icons.chevron_right,
                      color: _isToday(_selectedDate)
                          ? Colors.white38
                          : Colors.white,
                    ),
                    iconSize: 28,
                  ),
                ],
              ),
              if (_primaryChild != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.child_care_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Untuk ${_primaryChild!.name}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Nutrition rings card
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: DailyNutritionRings(
                  caloriesProgress: summary.caloriesPercent,
                  proteinProgress: summary.proteinPercent,
                  carbsProgress: summary.carbsPercent,
                  fatProgress: summary.fatPercent,
                  totalCalories: summary.totalCalories,
                  totalProtein: summary.totalProtein,
                  totalCarbs: summary.totalCarbs,
                  totalFat: summary.totalFat,
                ),
              ),
              if (_primaryChild != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _akgLabel(summary),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.primary,
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        tabs: _sessions.map((s) {
          return Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FoodDiaryService.sessionIcon(s), size: 14),
                const SizedBox(width: 6),
                Text(_shortLabel(s)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _shortLabel(String session) {
    switch (session) {
      case 'pagi':
        return 'Pagi';
      case 'siang':
        return 'Siang';
      case 'malam':
        return 'Malam';
      case 'snack':
        return 'Camilan';
      default:
        return session;
    }
  }

  void _showFoodSheet({required String session, FoodEntry? existingEntry}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FoodEditorSheet(
        session: session,
        userId: _userId,
        dateKey: FoodDiaryService.dateKey(_selectedDate),
        defaultChildId: _primaryChild?.id,
        existingEntry: existingEntry,
        onSave: (entry) {
          if (existingEntry == null) {
            _diaryService.addEntry(_selectedDate, entry);
          } else {
            _diaryService.updateEntry(_selectedDate, entry);
          }
          setState(() {});
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Tab konten per sesi
// ─────────────────────────────────────────────────

class _SessionTab extends StatelessWidget {
  final String session;
  final String userId;
  final DateTime date;
  final FoodDiaryService diaryService;
  final VoidCallback onEntryChanged;
  final ValueChanged<FoodEntry> onEdit;

  const _SessionTab({
    required this.session,
    required this.userId,
    required this.date,
    required this.diaryService,
    required this.onEntryChanged,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final entries = diaryService.getEntriesBySession(
      userId: userId,
      date: date,
      session: session,
    );
    final sessionSummary = diaryService.getSessionSummary(
      userId: userId,
      date: date,
      session: session,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        // Session summary bar
        if (entries.isNotEmpty)
          _SessionSummaryCard(summary: sessionSummary, session: session),
        if (entries.isNotEmpty) const SizedBox(height: 12),

        // Entry list
        if (entries.isEmpty)
          _EmptySession(session: session)
        else
          ...entries.map(
            (entry) => _FoodEntryCard(
              entry: entry,
              onEdit: () => onEdit(entry),
              onDelete: () {
                diaryService.removeEntry(
                  userId: userId,
                  date: date,
                  entryId: entry.id,
                );
                onEntryChanged();
              },
            ),
          ),
      ],
    );
  }
}

class _SessionSummaryCard extends StatelessWidget {
  final DailyNutritionSummary summary;
  final String session;

  const _SessionSummaryCard({required this.summary, required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniStat(
            '${summary.totalCalories.toStringAsFixed(0)} kkal',
            'Kalori',
            const Color(0xFFFF6B6B),
          ),
          _miniStat(
            '${summary.totalProtein.toStringAsFixed(1)} g',
            'Protein',
            const Color(0xFF00C9A7),
          ),
          _miniStat(
            '${summary.totalCarbs.toStringAsFixed(1)} g',
            'Karbo',
            const Color(0xFFFFB347),
          ),
          _miniStat(
            '${summary.totalFat.toStringAsFixed(1)} g',
            'Lemak',
            const Color(0xFF9B59B6),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: const Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }
}

class _EmptySession extends StatelessWidget {
  final String session;

  const _EmptySession({required this.session});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(
              FoodDiaryService.sessionIcon(session),
              size: 52,
              color: const Color(0xFFB2BEC3),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada makanan',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap "Tambah Makanan" untuk mencatat\nasupan ${FoodDiaryService.sessionLabel(session).toLowerCase()}',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF8E8E93),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodEntryCard extends StatelessWidget {
  final FoodEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FoodEntryCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B6B),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Food icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.foodName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.portionGram.toStringAsFixed(0)} gram · ${FoodDiaryService.sessionLabel(entry.session)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onEdit,
              tooltip: 'Edit ${entry.foodName}',
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.calories.toStringAsFixed(0)} kkal',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: const Color(0xFFFF6B6B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'P: ${entry.protein.toStringAsFixed(1)}g  K: ${entry.carbs.toStringAsFixed(1)}g',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Bottom Sheet: tambah makanan
// ─────────────────────────────────────────────────

class _FoodEditorSheet extends StatefulWidget {
  final String session;
  final String userId;
  final String dateKey;
  final String? defaultChildId;
  final FoodEntry? existingEntry;
  final void Function(FoodEntry entry) onSave;

  const _FoodEditorSheet({
    required this.session,
    required this.userId,
    required this.dateKey,
    required this.onSave,
    this.defaultChildId,
    this.existingEntry,
  });

  @override
  State<_FoodEditorSheet> createState() => _FoodEditorSheetState();
}

class _FoodEditorSheetState extends State<_FoodEditorSheet> {
  final _searchController = TextEditingController();
  final _portionController = TextEditingController();
  FoodItem? _selectedFood;
  List<FoodItem> _searchResults = FoodDatabase.items;
  String _selectedCategory = 'Semua';
  late String _session;
  String? _portionError;

  bool get isEditing => widget.existingEntry != null;

  @override
  void initState() {
    super.initState();
    _session = widget.existingEntry?.session ?? widget.session;
    final existing = widget.existingEntry;
    if (existing != null) {
      _selectedFood = FoodDatabase.findById(existing.foodItemId);
      _portionController.text = existing.portionGram.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _portionController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _searchResults = FoodDatabase.search(query);
      if (_selectedCategory != 'Semua') {
        _searchResults = _searchResults
            .where((f) => f.category == _selectedCategory)
            .toList();
      }
    });
  }

  void _onCategoryFilter(String cat) {
    setState(() {
      _selectedCategory = cat;
      _searchResults = cat == 'Semua'
          ? FoodDatabase.search(_searchController.text)
          : FoodDatabase.items.where((f) => f.category == cat).toList();
    });
  }

  void _selectFood(FoodItem item) {
    setState(() {
      _selectedFood = item;
      _portionController.text = item.defaultPortion.toStringAsFixed(0);
    });
  }

  void _saveEntry() {
    final food = _selectedFood;
    if (food == null) return;

    final gram = double.tryParse(_portionController.text.trim());
    if (gram == null || gram < 1 || gram > 2000) {
      setState(() {
        _portionError = 'Masukkan porsi antara 1 sampai 2000 gram';
      });
      return;
    }

    setState(() => _portionError = null);
    final existing = widget.existingEntry;
    final entry = food.toEntry(
      entryId: existing?.id ?? FoodDiaryService().generateId(),
      userId: widget.userId,
      dateKey: widget.dateKey,
      session: _session,
      gram: gram,
      childId: existing?.childId ?? widget.defaultChildId,
    );
    widget.onSave(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final categories = ['Semua', ...FoodDatabase.categories];

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE1E7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${isEditing ? 'Edit' : 'Tambah'} Makanan — ${FoodDiaryService.sessionLabel(_session)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D3436),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),

              if (!isEditing) ...[
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: 'Cari makanan...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFFB0B0B0),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF8E8E93),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F2F8),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Category filter chips
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    children: categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => _onCategoryFilter(cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFF0F2F8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF8E8E93),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // Food list
              Expanded(
                child: _selectedFood == null
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, i) {
                          final food = _searchResults[i];
                          return ListTile(
                            onTap: () => _selectFood(food),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.12,
                              ),
                              child: const Icon(
                                Icons.restaurant_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              food.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              '${food.caloriesPer100g.toStringAsFixed(0)} kkal / 100g · ${food.category}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF8E8E93),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      )
                    : _buildPortionSelector(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortionSelector() {
    final food = _selectedFood!;
    final parsedGram = double.tryParse(_portionController.text.trim());
    final gram = parsedGram != null && parsedGram > 0
        ? parsedGram
        : food.defaultPortion;
    final factor = gram / 100;
    final estCal = food.caloriesPer100g * factor;
    final estProt = food.proteinPer100g * factor;
    final estCarbs = food.carbsPer100g * factor;
    final estFat = food.fatPer100g * factor;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              if (isEditing) {
                Navigator.pop(context);
              } else {
                setState(() => _selectedFood = null);
              }
            },
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                Text(
                  'Kembali ke daftar',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Food info
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: const Color(0xFF2D3436),
                      ),
                    ),
                    Text(
                      food.category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (isEditing) ...[
            Text(
              'Sesi Makan',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: const Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _session,
              items: FoodDiaryService.sessions
                  .map(
                    (session) => DropdownMenuItem(
                      value: session,
                      child: Text(FoodDiaryService.sessionLabel(session)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _session = value);
              },
            ),
            const SizedBox(height: 20),
          ],

          // Portion input
          Text(
            'Jumlah (gram)',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: const Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _portionController,
            onChanged: (_) => setState(() => _portionError = null),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Masukkan jumlah gram',
              suffixText: 'gram',
              errorText: _portionError,
              filled: true,
              fillColor: const Color(0xFFF0F2F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Default: ${food.defaultPortion.toStringAsFixed(0)} gram (1 ${food.defaultUnit})',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 20),

          // Nutrition preview
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimasi Gizi',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _nutritionPreviewItem(
                      '${estCal.toStringAsFixed(0)} kkal',
                      'Kalori',
                      const Color(0xFFFF6B6B),
                    ),
                    _nutritionPreviewItem(
                      '${estProt.toStringAsFixed(1)} g',
                      'Protein',
                      const Color(0xFF00C9A7),
                    ),
                    _nutritionPreviewItem(
                      '${estCarbs.toStringAsFixed(1)} g',
                      'Karbo',
                      const Color(0xFFFFB347),
                    ),
                    _nutritionPreviewItem(
                      '${estFat.toStringAsFixed(1)} g',
                      'Lemak',
                      const Color(0xFF9B59B6),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                isEditing
                    ? 'Simpan Perubahan'
                    : 'Tambahkan ke ${FoodDiaryService.sessionLabel(_session)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutritionPreviewItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }
}
