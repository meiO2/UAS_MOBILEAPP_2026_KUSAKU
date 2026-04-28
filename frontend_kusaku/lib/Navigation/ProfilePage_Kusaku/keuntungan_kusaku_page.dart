import 'package:flutter/material.dart';

class KeuntunganKusakuPage extends StatelessWidget {
  const KeuntunganKusakuPage({super.key});

  static const List<_KeuntunganItem> _items = [
    _KeuntunganItem(
      title: 'Atur Keuangan dengan Mudah',
      imagePath: 'images/itu/rotasi1.png',
      description: 'Nikmati layanan keuangan dari A.I Kusaku "SI PINTAR"',
    ),
    _KeuntunganItem(
      title: 'Pencatatan Keuangan Otomatis',
      imagePath: 'images/itu/rotasi2.png',
      description:
          'Pantau pengeluaran harian, mingguan, sampai bulanan\ntanpa perlu mencatat keuangan',
    ),
    _KeuntunganItem(
      title: 'Keamanan Lebih terjamin',
      imagePath: 'images/itu/rotasi3.png',
      description: 'Data pribadi dan saldo akan terjaga keamanannya',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text(
          'Keuntungan Pakai Kusaku',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _KeuntunganCard(item: _items[index]),
      ),
    );
  }
}

class _KeuntunganCard extends StatelessWidget {
  final _KeuntunganItem item;
  const _KeuntunganCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),

          const SizedBox(height: 16),

          // Image
          Flexible(
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 22, color: Colors.grey.shade400),
                  const SizedBox(height: 6),
                  Text(
                    item.imagePath,
                    style: 
                    TextStyle(fontSize: 14, color: Colors.grey.shade400, height: 22),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 2),

          // Description
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280),
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeuntunganItem {
  final String title;
  final String imagePath;
  final String description;
  const _KeuntunganItem({
    required this.title,
    required this.imagePath,
    required this.description,
  });
}