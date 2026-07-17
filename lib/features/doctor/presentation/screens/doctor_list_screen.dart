import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/doctor_model.dart';
import '../providers/doctor_provider.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      Provider.of<DoctorProvider>(context, listen: false)
          .setSearchQuery(_searchController.text);
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getAvailability(DoctorModel doc) {
    if (doc.status != 'Active' || doc.availableDays.isEmpty) {
      return {'label': 'Unavailable', 'color': const Color(0xFFEF4444)};
    }

    final now = DateTime.now();
    final todayStr = DateFormat('EEEE').format(now);
    final tomorrowStr = DateFormat('EEEE').format(now.add(const Duration(days: 1)));

    if (doc.availableDays.contains(todayStr)) {
      return {'label': 'Available Today', 'color': const Color(0xFF10B981)};
    } else if (doc.availableDays.contains(tomorrowStr)) {
      return {'label': 'Tomorrow', 'color': const Color(0xFFF59E0B)};
    } else {
      return {'label': 'Unavailable', 'color': const Color(0xFFEF4444)};
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<DoctorProvider>(context);
    final list = provider.doctors;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.currentUser?.role == 'Admin';

    // Filter local specialties list
    final allowedSpecialties = [
      'All',
      'General Physician',
      'Cardiology',
      'Dermatology',
      'Neurology',
      'Orthopedics',
      'Pediatrics',
      'Gynecology',
      'Dentistry',
      'ENT',
      'Psychiatry',
      'Ophthalmology'
    ];
    final activeSpecialties = allowedSpecialties
        .where((spec) => spec == 'All' || provider.specializations.contains(spec))
        .toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Find Your Doctor',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.loadDoctors(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Choose the right specialist for your healthcare needs.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search Field & Sort Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Search doctors, specialties...',
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      ),
                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: PopupMenuButton<DoctorSortOption>(
                    icon: const Icon(Icons.swap_vert_rounded, color: Color(0xFF2563EB)),
                    tooltip: 'Sort Doctors',
                    onSelected: (option) => provider.setSortOption(option),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: DoctorSortOption.name,
                        child: Text('Sort by Name'),
                      ),
                      const PopupMenuItem(
                        value: DoctorSortOption.experience,
                        child: Text('Sort by Experience'),
                      ),
                      const PopupMenuItem(
                        value: DoctorSortOption.consultationFee,
                        child: Text('Sort by Fee'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Horizontally Scrollable Specialty Filters
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: activeSpecialties.length,
              itemBuilder: (context, index) {
                final spec = activeSpecialties[index];
                final isSelected = provider.filterSpecialization == spec;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      spec,
                      style: TextStyle(
                        color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : const Color(0xFF475569)),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      provider.setFilterSpecialization(spec);
                    },
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Main Directory List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadDoctors(),
              child: _buildListContent(provider, list, theme, isDark),
            ),
          ),

          // Pagination Controls
          if (provider.allDoctors.isNotEmpty && !provider.isLoading && provider.errorMessage == null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: provider.hasPreviousPage ? () => provider.previousPage() : null,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                    label: const Text('Prev'),
                  ),
                  Text(
                    'Page ${provider.currentPage}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: provider.hasNextPage ? () => provider.nextPage() : null,
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    label: const Text('Next'),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.doctorDetail, arguments: null);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Doctor'),
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildListContent(DoctorProvider provider, List<DoctorModel> list, ThemeData theme, bool isDark) {
    if (provider.isLoading) {
      return const Center(child: LoadingIndicator(message: 'Loading clinical directory...'));
    }

    if (provider.errorMessage != null) {
      return Center(
        child: CustomErrorWidget(
          errorMessage: provider.errorMessage!,
          onRetry: () => provider.loadDoctors(),
        ),
      );
    }

    if (list.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text(
                'No doctors found.',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your keywords or filters.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  provider.resetFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final doc = list[index];
        final availability = _getAvailability(doc);

        final double delay = (index % 5) * 0.1;
        final entryAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, delay + 0.5, curve: Curves.easeOut),
          ),
        );

        return FadeTransition(
          opacity: entryAnimation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(delay, delay + 0.5, curve: Curves.easeOutCubic),
              ),
            ),
            child: Hero(
              tag: 'doc_card_${doc.doctorId}',
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.doctorDetail,
                      arguments: doc,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Doctor Avatar
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              backgroundImage: doc.profileImage != null
                                  ? NetworkImage(doc.profileImage!)
                                  : null,
                              child: doc.profileImage == null
                                  ? Icon(Icons.person_rounded, size: 32, color: theme.colorScheme.primary)
                                  : null,
                            ),
                            const SizedBox(width: 16),

                            // Doctor Credentials Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          doc.fullName,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Placed star rating label
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                          const SizedBox(width: 2),
                                          Text(
                                            '4.8',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.grey[300] : const Color(0xFF334155),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${doc.specialization} • ${doc.experience} Yrs Experience',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF2563EB),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.local_hospital_outlined, size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          doc.hospitalName.isNotEmpty ? doc.hospitalName : 'Clinic Hospital',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), height: 1),
                        const SizedBox(height: 12),

                        // Pricing, Availability and Booking trigger
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Consultation Fee',
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                                ),
                                Text(
                                  '\$${doc.consultationFee.toStringAsFixed(0)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            // Availability badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: (availability['color'] as Color).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                availability['label'] as String,
                                style: TextStyle(
                                  color: availability['color'] as Color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            // Book Button
                            Container(
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2563EB), Color(0xFF14B8A6)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.doctorDetail,
                                    arguments: doc,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Book Appointment',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
