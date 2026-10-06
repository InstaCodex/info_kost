import 'package:flutter/material.dart';
import 'models.dart';

void main() {
  runApp(const InfoKostApp());
}

// Format mata uang sederhana tanpa package tambahan
String formatRupiah(int number) {
  final str = number.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(str[i]);
  }
  return 'Rp${buffer.toString()}';
}

class InfoKostApp extends StatefulWidget {
  const InfoKostApp({super.key});

  @override
  State<InfoKostApp> createState() => _InfoKostAppState();
}

class _InfoKostAppState extends State<InfoKostApp> {
  // Global local state untuk data Kost agar sinkron antar halaman
  final List<Kost> _kostList = List.from(initialKostList);

  void _addKost(Kost kost) {
    setState(() {
      _kostList.insert(0, kost);
    });
  }

  void _editKost(Kost updatedKost) {
    setState(() {
      final index = _kostList.indexWhere((k) => k.id == updatedKost.id);
      if (index != -1) {
        _kostList[index] = updatedKost;
      }
    });
  }

  void _deleteKost(String id) {
    setState(() {
      _kostList.removeWhere((k) => k.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InfoKost',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1.5,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
        ),
      ),
      home: MainNavigation(
        kostList: _kostList,
        onAddKost: _addKost,
        onEditKost: _editKost,
        onDeleteKost: _deleteKost,
      ),
    );
  }
}

// ==========================================
// 1. NAVIGASI UTAMA PENCARI KOST
// ==========================================
class MainNavigation extends StatefulWidget {
  final List<Kost> kostList;
  final Function(Kost) onAddKost;
  final Function(Kost) onEditKost;
  final Function(String) onDeleteKost;

  const MainNavigation({
    super.key,
    required this.kostList,
    required this.onAddKost,
    required this.onEditKost,
    required this.onDeleteKost,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        kostList: widget.kostList,
        autoFocusSearch: false,
      ),
      HomePage(
        kostList: widget.kostList,
        autoFocusSearch: true,
      ),
      ProfileRoleSelectorPage(
        kostList: widget.kostList,
        onAddKost: widget.onAddKost,
        onEditKost: widget.onEditKost,
        onDeleteKost: widget.onDeleteKost,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 4,
        indicatorColor: const Color(0xFFE0E7FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF2563EB)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: Color(0xFF2563EB)),
            label: 'Cari',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF2563EB)),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. HALAMAN HOME & CARI KOST
// ==========================================
class HomePage extends StatefulWidget {
  final List<Kost> kostList;
  final bool autoFocusSearch;

  const HomePage({
    super.key,
    required this.kostList,
    this.autoFocusSearch = false,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocation = 'Semua';
  String _selectedType = 'Semua';

  final List<String> _locations = ['Semua', 'Pemalang', 'Pekalongan', 'Tegal'];
  final List<String> _types = ['Semua', 'Putra', 'Putri', 'Campur'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    // Filter data kost
    final filteredKost = widget.kostList.where((kost) {
      final matchesQuery = kost.name.toLowerCase().contains(query) ||
          kost.location.toLowerCase().contains(query);
      final matchesLocation = _selectedLocation == 'Semua' ||
          kost.location.toLowerCase() == _selectedLocation.toLowerCase();
      final matchesType = _selectedType == 'Semua' ||
          kost.type.toLowerCase() == _selectedType.toLowerCase();

      return matchesQuery && matchesLocation && matchesType;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.home_work, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'InfoKost',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Cari Kost Nyaman & Murah',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cari Kost',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    autofocus: widget.autoFocusSearch,
                    onChanged: (val) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari nama kost atau lokasi...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Sederhana: Lokasi & Tipe Kost
                  Row(
                    children: [
                      // Filter Lokasi
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLocation,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                              items: _locations.map((loc) {
                                return DropdownMenuItem(
                                  value: loc,
                                  child: Text(
                                    'Lokasi: $loc',
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedLocation = val);
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Filter Tipe
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedType,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                              items: _types.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    'Tipe: $type',
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedType = val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Label Hasil
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Rekomendasi Kost',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '${filteredKost.length} kost ditemukan',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Daftar Kost Cards
          filteredKost.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'Tidak ada kost yang sesuai',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Coba ganti kata kunci atau reset filter',
                            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final kost = filteredKost[index];
                        return KostCard(
                          kost: kost,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailKostPage(kost: kost),
                              ),
                            );
                          },
                        );
                      },
                      childCount: filteredKost.length,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// Widget Card Kost
class KostCard extends StatelessWidget {
  final Kost kost;
  final VoidCallback onTap;

  const KostCard({super.key, required this.kost, required this.onTap});

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'putra':
        return const Color(0xFF2563EB); // Biru
      case 'putri':
        return const Color(0xFFDB2777); // Pink/Rose
      default:
        return const Color(0xFF059669); // Hijau/Campur
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto Kost
            Stack(
              children: [
                SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: Image.network(
                    kost.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE2E8F0),
                      child: const Center(
                        child: Icon(Icons.image_not_supported, color: Color(0xFF94A3B8), size: 40),
                      ),
                    ),
                  ),
                ),
                // Badge Tipe
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(kost.type),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      kost.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Informasi Kost
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kost.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        kost.location,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        formatRupiah(kost.price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const Text(
                        ' / bulan',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. HALAMAN DETAIL KOST
// ==========================================
class DetailKostPage extends StatelessWidget {
  final Kost kost;

  const DetailKostPage({super.key, required this.kost});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kost', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto Header
            SizedBox(
              height: 240,
              width: double.infinity,
              child: Image.network(
                kost.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFE2E8F0),
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Color(0xFF94A3B8), size: 50),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama & Tipe
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          kost.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          kost.type,
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Lokasi
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        kost.location,
                        style: const TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Harga
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Harga Sewa',
                          style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: formatRupiah(kost.price),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                              const TextSpan(
                                text: ' / bulan',
                                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Fasilitas (3-5 fasilitas)
                  const Text(
                    'Fasilitas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kost.facilities.map((f) {
                      return Chip(
                        avatar: const Icon(Icons.check_circle, size: 16, color: Color(0xFF2563EB)),
                        label: Text(f, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Deskripsi Singkat
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kost.description,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // Kontak Pemilik
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFE0E7FF),
                          child: Icon(Icons.person, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kost.ownerName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                            Text(
                              'WhatsApp: ${kost.ownerPhone}',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90), // Ruang untuk bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.phone),
            label: const Text(
              'Hubungi Pemilik',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              // Dialog / snackbar info WhatsApp
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF0F172A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  content: Text('Hubungi pemilik melalui WhatsApp (${kost.ownerPhone})'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. ROLE SELECTOR / TAB PROFIL
// ==========================================
class ProfileRoleSelectorPage extends StatelessWidget {
  final List<Kost> kostList;
  final Function(Kost) onAddKost;
  final Function(Kost) onEditKost;
  final Function(String) onDeleteKost;

  const ProfileRoleSelectorPage({
    super.key,
    required this.kostList,
    required this.onAddKost,
    required this.onEditKost,
    required this.onDeleteKost,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Akses Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE2E8F0),
              child: Icon(Icons.person, size: 44, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pengguna InfoKost',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const Text(
              'Pencari Kost Aktif',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 28),

            // Card Menu Role Pemilik Kost
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.business_center, color: Color(0xFF2563EB)),
                ),
                title: const Text('Login Pemilik Kost', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Kelola kost yang Anda sewakan'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OwnerLoginPage(
                        kostList: kostList,
                        onAddKost: onAddKost,
                        onEditKost: onEditKost,
                        onDeleteKost: onDeleteKost,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Card Menu Role Admin
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.admin_panel_settings, color: Color(0xFFDC2626)),
                ),
                title: const Text('Login Admin', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Akses dashboard data InfoKost'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminLoginPage(kostList: kostList),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // Keterangan Project Belajar
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFF64748B)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aplikasi InfoKost adalah project pembelajaran antarmuka (UI/UX) dan navigasi dengan dummy data.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. LOGIN PEMILIK KOST
// ==========================================
class OwnerLoginPage extends StatefulWidget {
  final List<Kost> kostList;
  final Function(Kost) onAddKost;
  final Function(Kost) onEditKost;
  final Function(String) onDeleteKost;

  const OwnerLoginPage({
    super.key,
    required this.kostList,
    required this.onAddKost,
    required this.onEditKost,
    required this.onDeleteKost,
  });

  @override
  State<OwnerLoginPage> createState() => _OwnerLoginPageState();
}

class _OwnerLoginPageState extends State<OwnerLoginPage> {
  final _usernameController = TextEditingController(text: 'pemilik');
  final _passwordController = TextEditingController(text: '123456');

  void _handleLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerMainNavigation(
          kostList: widget.kostList,
          onAddKost: widget.onAddKost,
          onEditKost: widget.onEditKost,
          onDeleteKost: widget.onDeleteKost,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Pemilik')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFEFF6FF),
                child: Icon(Icons.business_center, size: 36, color: Color(0xFF2563EB)),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Selamat Datang, Pemilik',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ),
            const Center(
              child: Text(
                'Masuk untuk mengelola kost Anda',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Username / Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: 'Masukkan username',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Masukkan password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _handleLogin,
                child: const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '*Login dummy: langsung tekan tombol Masuk',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Navigasi Pemilik: Kost Saya | Profil
class OwnerMainNavigation extends StatefulWidget {
  final List<Kost> kostList;
  final Function(Kost) onAddKost;
  final Function(Kost) onEditKost;
  final Function(String) onDeleteKost;

  const OwnerMainNavigation({
    super.key,
    required this.kostList,
    required this.onAddKost,
    required this.onEditKost,
    required this.onDeleteKost,
  });

  @override
  State<OwnerMainNavigation> createState() => _OwnerMainNavigationState();
}

class _OwnerMainNavigationState extends State<OwnerMainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      OwnerKostListPage(
        kostList: widget.kostList,
        onAddKost: widget.onAddKost,
        onEditKost: widget.onEditKost,
        onDeleteKost: widget.onDeleteKost,
      ),
      OwnerProfilePage(
        onLogout: () {
          Navigator.pop(context);
        },
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: Colors.white,
        elevation: 4,
        indicatorColor: const Color(0xFFE0E7FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment, color: Color(0xFF2563EB)),
            label: 'Kost Saya',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF2563EB)),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. HALAMAN KOST SAYA (PEMILIK)
// ==========================================
class OwnerKostListPage extends StatelessWidget {
  final List<Kost> kostList;
  final Function(Kost) onAddKost;
  final Function(Kost) onEditKost;
  final Function(String) onDeleteKost;

  const OwnerKostListPage({
    super.key,
    required this.kostList,
    required this.onAddKost,
    required this.onEditKost,
    required this.onDeleteKost,
  });

  void _confirmDelete(BuildContext context, Kost kost) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kost'),
        content: Text('Apakah Anda yakin ingin menghapus "${kost.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              onDeleteKost(kost.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kost "${kost.name}" berhasil dihapus'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kost Saya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Kembali ke Pencari Kost',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: kostList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('Belum ada kost terdaftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Tekan tombol di bawah untuk menambah kost baru', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kostList.length,
              itemBuilder: (context, index) {
                final kost = kostList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto kecil
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.network(
                              kost.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, error, stackTrace) => Container(
                                color: const Color(0xFFE2E8F0),
                                child: const Icon(Icons.image_not_supported, size: 24, color: Color(0xFF94A3B8)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Informasi
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kost.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${kost.location} • ${kost.type}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${formatRupiah(kost.price)}/bln',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2563EB)),
                              ),
                            ],
                          ),
                        ),

                        // Action Edit & Hapus
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF2563EB)),
                              tooltip: 'Edit Kost',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditKostPage(
                                      kostToEdit: kost,
                                      onSave: onEditKost,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFDC2626)),
                              tooltip: 'Hapus Kost',
                              onPressed: () => _confirmDelete(context, kost),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditKostPage(
                onSave: onAddKost,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kost'),
      ),
    );
  }
}

// Profil Pemilik Sederhana
class OwnerProfilePage extends StatelessWidget {
  final VoidCallback onLogout;

  const OwnerProfilePage({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pemilik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFEFF6FF),
              child: Icon(Icons.person, size: 44, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Bapak Sukardi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const Text(
              'pemilik@infokost.com | 081234567890',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Keluar (Ganti Role)'),
                onPressed: onLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 7. FORM TAMBAH / EDIT KOST
// ==========================================
class AddEditKostPage extends StatefulWidget {
  final Kost? kostToEdit;
  final Function(Kost) onSave;

  const AddEditKostPage({
    super.key,
    this.kostToEdit,
    required this.onSave,
  });

  @override
  State<AddEditKostPage> createState() => _AddEditKostPageState();
}

class _AddEditKostPageState extends State<AddEditKostPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _facilitiesController;
  late TextEditingController _descController;
  late TextEditingController _imageController;
  late TextEditingController _phoneController;
  late String _selectedType;

  final List<String> _types = ['Putra', 'Putri', 'Campur'];

  @override
  void initState() {
    super.initState();
    final k = widget.kostToEdit;
    _nameController = TextEditingController(text: k?.name ?? '');
    _priceController = TextEditingController(text: k != null ? k.price.toString() : '');
    _locationController = TextEditingController(text: k?.location ?? '');
    _facilitiesController = TextEditingController(text: k != null ? k.facilities.join(', ') : 'WiFi Gratis, Kamar Mandi Dalam, Kasur & Lemari');
    _descController = TextEditingController(text: k?.description ?? '');
    _imageController = TextEditingController(
      text: k?.imageUrl ?? 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
    );
    _phoneController = TextEditingController(text: k?.ownerPhone ?? '081234567890');
    _selectedType = k?.type ?? 'Putra';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _facilitiesController.dispose();
    _descController.dispose();
    _imageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final facilitiesList = _facilitiesController.text
          .split(',')
          .map((f) => f.trim())
          .where((f) => f.isNotEmpty)
          .toList();

      final priceInt = int.tryParse(_priceController.text.trim()) ?? 0;

      final newOrUpdatedKost = Kost(
        id: widget.kostToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        price: priceInt,
        type: _selectedType,
        imageUrl: _imageController.text.trim().isNotEmpty
            ? _imageController.text.trim()
            : 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
        facilities: facilitiesList.isNotEmpty ? facilitiesList : ['Fasilitas Standar'],
        description: _descController.text.trim(),
        ownerPhone: _phoneController.text.trim(),
        ownerName: widget.kostToEdit?.ownerName ?? 'Bapak Sukardi',
      );

      widget.onSave(newOrUpdatedKost);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.kostToEdit == null ? 'Kost berhasil ditambahkan!' : 'Data kost berhasil diperbarui!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.kostToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Kost' : 'Tambah Kost', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Kost
              const Text('Nama Kost *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Contoh: Kost Flamboyan'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Nama kost wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Harga & Tipe
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Harga per Bulan (Rp) *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '750000'),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Harga wajib diisi';
                            if (int.tryParse(val.trim()) == null) return 'Harus angka';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tipe Kost', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedType,
                              isExpanded: true,
                              items: _types.map((t) {
                                return DropdownMenuItem(value: t, child: Text(t));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedType = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lokasi
              const Text('Lokasi / Kota *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(hintText: 'Contoh: Pemalang'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Lokasi wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Fasilitas
              const Text('Fasilitas (pisahkan dengan koma)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _facilitiesController,
                decoration: const InputDecoration(hintText: 'WiFi, AC, Kasur, Kamar Mandi Dalam'),
              ),
              const SizedBox(height: 16),

              // Deskripsi
              const Text('Deskripsi Singkat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Deskripsi lingkungan, akses, dan keunggulan kost...'),
              ),
              const SizedBox(height: 16),

              // Nomor WhatsApp
              const Text('Nomor WhatsApp Pemilik', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'Contoh: 081234567890'),
              ),
              const SizedBox(height: 16),

              // URL Foto Kost
              const Text('URL Foto Kost', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(hintText: 'https://... (URL Gambar)'),
              ),
              const SizedBox(height: 28),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _submit,
                  child: Text(
                    isEditing ? 'Simpan Perubahan' : 'Tambah Kost',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 8. LOGIN ADMIN
// ==========================================
class AdminLoginPage extends StatefulWidget {
  final List<Kost> kostList;

  const AdminLoginPage({super.key, required this.kostList});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _adminUser = TextEditingController(text: 'admin');
  final _adminPass = TextEditingController(text: 'admin123');

  void _handleAdminLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboardPage(kostList: widget.kostList),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Admin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFFEF2F2),
                child: Icon(Icons.admin_panel_settings, size: 36, color: Color(0xFFDC2626)),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Panel Administrator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ),
            const Center(
              child: Text(
                'Masuk ke dashboard kontrol InfoKost',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Username Admin', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _adminUser,
              decoration: const InputDecoration(
                hintText: 'admin',
                prefixIcon: Icon(Icons.shield_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Password Admin', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _adminPass,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: '••••••••',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _handleAdminLogin,
                child: const Text('Masuk Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '*Login dummy: langsung tekan tombol Masuk Admin',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 9. DASHBOARD ADMIN
// ==========================================
class AdminDashboardPage extends StatelessWidget {
  final List<Kost> kostList;

  const AdminDashboardPage({super.key, required this.kostList});

  @override
  Widget build(BuildContext context) {
    final totalKost = kostList.length;
    final totalOwners = dummyOwners.length;
    final totalFacilities = dummyMasterFacilities.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Logout Admin',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // 3 Kartu Angka Statistik
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Kost',
                    value: '$totalKost',
                    icon: Icons.apartment,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Total Pemilik',
                    value: '$totalOwners',
                    icon: Icons.people,
                    color: const Color(0xFF059669),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Total Fasilitas',
                    value: '$totalFacilities',
                    icon: Icons.meeting_room,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Menu Master Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // Menu 1: Data Kost
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.apartment, color: Color(0xFF2563EB)),
                ),
                title: const Text('Data Kost', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('$totalKost kost terdaftar'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminKostListPage(kostList: kostList),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Menu 2: Data Pemilik
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.people, color: Color(0xFF059669)),
                ),
                title: const Text('Data Pemilik', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('$totalOwners pemilik aktif'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminOwnerListPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Menu 3: Fasilitas
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.list_alt, color: Color(0xFFD97706)),
                ),
                title: const Text('Fasilitas', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('$totalFacilities jenis fasilitas'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminFacilitiesListPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Komponen Card Statistik
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// Sub-halaman Admin: Data Kost
class AdminKostListPage extends StatelessWidget {
  final List<Kost> kostList;

  const AdminKostListPage({super.key, required this.kostList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Kost (Admin)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kostList.length,
        itemBuilder: (context, index) {
          final kost = kostList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text('${index + 1}', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
              ),
              title: Text(kost.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${kost.location} • ${kost.type} • ${formatRupiah(kost.price)}/bln'),
              trailing: const Icon(Icons.check_circle_outline, color: Color(0xFF059669), size: 20),
            ),
          );
        },
      ),
    );
  }
}

// Sub-halaman Admin: Data Pemilik
class AdminOwnerListPage extends StatelessWidget {
  const AdminOwnerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Pemilik (Admin)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyOwners.length,
        itemBuilder: (context, index) {
          final owner = dummyOwners[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFECFDF5),
                child: Icon(Icons.person, color: Color(0xFF059669)),
              ),
              title: Text(owner.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('No. HP: ${owner.phone}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${owner.totalKost} Kost',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Sub-halaman Admin: Fasilitas
class AdminFacilitiesListPage extends StatelessWidget {
  const AdminFacilitiesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Fasilitas (Admin)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyMasterFacilities.length,
        itemBuilder: (context, index) {
          final fac = dummyMasterFacilities[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.check_box, color: Color(0xFF2563EB)),
              title: Text(fac, style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          );
        },
      ),
    );
  }
}
