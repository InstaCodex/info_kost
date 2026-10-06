// Model data sederhana untuk Kost
class Kost {
  final String id;
  String name;
  String location;
  int price;
  String type; // 'Putra', 'Putri', 'Campur'
  String imageUrl;
  List<String> facilities;
  String description;
  String ownerPhone;
  String ownerName;

  Kost({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.type,
    required this.imageUrl,
    required this.facilities,
    required this.description,
    required this.ownerPhone,
    this.ownerName = 'Bapak Sukardi',
  });
}

// Model data pemilik kost untuk role Admin
class Owner {
  final String id;
  final String name;
  final String phone;
  final int totalKost;

  Owner({
    required this.id,
    required this.name,
    required this.phone,
    required this.totalKost,
  });
}

// Dummy data awal
final List<Kost> initialKostList = [
  Kost(
    id: '1',
    name: 'Kost Mawar',
    location: 'Pemalang',
    price: 750000,
    type: 'Putra',
    imageUrl: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
    facilities: ['Kasur & Bantal', 'Lemari Pakaian', 'Kamar Mandi Dalam', 'WiFi Gratis', 'Parkir Motor'],
    description: 'Kost nyaman, tenang, dan strategis dekat dengan pusat kota Pemalang. Lingkungan aman dan bersih dengan akses 24 jam.',
    ownerPhone: '081234567890',
    ownerName: 'Bapak Sukardi',
  ),
  Kost(
    id: '2',
    name: 'Kost Melati',
    location: 'Pemalang',
    price: 650000,
    type: 'Putri',
    imageUrl: 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=600&q=80',
    facilities: ['Kasur Springbed', 'Meja Belajar', 'Dapur Bersama', 'WiFi', 'CCTV 24 Jam'],
    description: 'Kost khusus putri yang asri, sejuk, dan terawat. Sangat cocok untuk mahasiswi maupun karyawati yang mengutamakan privasi dan kenyamanan.',
    ownerPhone: '081398765432',
    ownerName: 'Ibu Rahayu',
  ),
  Kost(
    id: '3',
    name: 'Kost Harmoni',
    location: 'Pekalongan',
    price: 850000,
    type: 'Campur',
    imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=600&q=80',
    facilities: ['AC', 'Kamar Mandi Dalam', 'Kasur Queen Size', 'WiFi Kencang', 'Parkir Mobil & Motor'],
    description: 'Kost eksklusif ber-AC di Pekalongan dengan fasilitas lengkap. Akses dekat ke jalan protokol dan pusat kuliner.',
    ownerPhone: '085712345678',
    ownerName: 'Bapak Hendra',
  ),
  Kost(
    id: '4',
    name: 'Kost Sejahtera',
    location: 'Tegal',
    price: 900000,
    type: 'Putra',
    imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?auto=format&fit=crop&w=600&q=80',
    facilities: ['Kamar Mandi Dalam', 'AC', 'Water Heater', 'Meja Kerja', 'Security'],
    description: 'Hunian modern untuk pria berlokasi di pusat kota Tegal. Dekat stasiun, minimarket, dan fasilitas umum lainnya.',
    ownerPhone: '087811223344',
    ownerName: 'Bapak Bambang',
  ),
];

// Dummy data pemilik kost untuk Admin
final List<Owner> dummyOwners = [
  Owner(id: '1', name: 'Bapak Sukardi', phone: '081234567890', totalKost: 2),
  Owner(id: '2', name: 'Ibu Rahayu', phone: '081398765432', totalKost: 1),
  Owner(id: '3', name: 'Bapak Hendra', phone: '085712345678', totalKost: 1),
  Owner(id: '4', name: 'Bapak Bambang', phone: '087811223344', totalKost: 1),
];

// Dummy daftar master fasilitas
final List<String> dummyMasterFacilities = [
  'WiFi Gratis',
  'Kamar Mandi Dalam',
  'AC',
  'Kasur & Lemari',
  'Parkir Motor',
  'Parkir Mobil',
  'Dapur Bersama',
  'CCTV 24 Jam',
  'Water Heater',
];
