import 'package:flutter/material.dart';

class PusatBantuanPage extends StatefulWidget {
  const PusatBantuanPage({super.key});

  @override
  State<PusatBantuanPage> createState() => _PusatBantuanPageState();
}

class _PusatBantuanPageState extends State<PusatBantuanPage> {
  String? _expandedSection;

  final List<_HelpSection> _sections = const [
    _HelpSection(
      title: 'Akun dan Pengaturan',
      items: [
        _HelpItem(
          question: 'Bagaimana cara mengubah nama profil saya?',
          answer:
              'Buka halaman Profile, lalu tekan tombol "Ubah" di samping nama kamu. Kamu bisa mengganti nama lengkap langsung dari halaman Ubah Profile dan tekan "Simpan" untuk menyimpan perubahan.',
        ),
        _HelpItem(
          question: 'Bagaimana cara mengganti nomor HP atau email?',
          answer:
              'Di halaman Ubah Profile, tekan tombol "Ubah" di samping Nomor HP atau Email. Kamu akan diminta untuk memverifikasi identitasmu terlebih dahulu sebelum bisa mengubah informasi tersebut.',
        ),
        _HelpItem(
          question: 'Apa itu Security Code dan bagaimana cara mengubahnya?',
          answer:
              'Security Code adalah PIN 6 digit yang digunakan untuk mengonfirmasi transaksi seperti Transfer dan Top Up. Kamu bisa mengubahnya melalui Profile → Keamanan → Ubah Security Code.',
        ),
        _HelpItem(
          question: 'Bagaimana cara mengaktifkan Fingerprint?',
          answer:
              'Masuk ke Profile → Keamanan, lalu aktifkan toggle Fingerprint. Pastikan perangkatmu sudah mendaftarkan sidik jari di pengaturan sistem sebelum mengaktifkan fitur ini.',
        ),
      ],
    ),
    _HelpSection(
      title: 'Transfer',
      items: [
        _HelpItem(
          question: 'Bagaimana cara melakukan transfer ke sesama pengguna Kusaku?',
          answer:
              'Dari halaman Home, tekan tombol "Transfer" pada kartu saldo. Pilih metode "Kusaku", cari dan pilih penerima, tentukan jumlah yang ingin ditransfer, tambahkan pesan jika perlu, lalu konfirmasi dengan memasukkan Security Code kamu.',
        ),
        _HelpItem(
          question: 'Berapa batas maksimal transfer?',
          answer:
              'Batas maksimal transfer per transaksi adalah Rp 30.000.000. Jika kamu perlu mentransfer lebih dari jumlah tersebut, kamu perlu melakukan beberapa kali transaksi.',
        ),
        _HelpItem(
          question: 'Apa saja metode transfer yang tersedia?',
          answer:
              'Kusaku mendukung tiga metode transfer: Kusaku (sesama pengguna Kusaku), Bank Lain (transfer ke rekening bank lain), dan Virtual Account. Pilih metode yang sesuai saat memulai transaksi transfer.',
        ),
        _HelpItem(
          question: 'Apakah transfer dikenakan biaya?',
          answer:
              'Transfer antar sesama pengguna Kusaku tidak dikenakan biaya tambahan. Untuk transfer ke bank lain atau virtual account, mungkin dikenakan biaya sesuai kebijakan yang berlaku. Detail biaya akan ditampilkan sebelum kamu mengonfirmasi transaksi.',
        ),
      ],
    ),
    _HelpSection(
      title: 'Pembayaran',
      items: [
        _HelpItem(
          question: 'Bagaimana cara membayar menggunakan Qris Kita?',
          answer:
              'Tekan tombol scan (lingkaran biru) di navbar bawah, atau akses Qris Kita dari halaman Home. Tampilkan QR code kamu ke kasir, dan kasir akan melakukan scan untuk memproses pembayaran.',
        ),
        _HelpItem(
          question: 'Apakah saya bisa membeli pulsa melalui Kusaku?',
          answer:
              'Ya! Dari Home tekan "Top Up", lalu pilih "Pulsa". Pilih paket pulsa yang kamu inginkan, konfirmasi pembayaran, dan masukkan Security Code kamu. Pulsa akan langsung terisi ke nomor yang terdaftar.',
        ),
        _HelpItem(
          question: 'Apa saja metode Top Up yang tersedia?',
          answer:
              'Kamu bisa Top Up saldo Kusaku melalui Pulsa, Alfamart, Indomaret, dan Lawson. Pilih metode yang paling nyaman bagimu dari halaman Top Up.',
        ),
        _HelpItem(
          question: 'Berapa batas maksimal Top Up?',
          answer:
              'Batas maksimal Top Up per transaksi adalah Rp 10.000.000. Fee sebesar 20% akan dikenakan untuk setiap transaksi Top Up.',
        ),
      ],
    ),
    _HelpSection(
      title: 'Top UP dan Tagihan',
      items: [
        _HelpItem(
          question: 'Berapa lama proses Top Up melalui minimarket?',
          answer:
              'Top Up melalui Alfamart, Indomaret, atau Lawson biasanya diproses dalam waktu 1–5 menit setelah pembayaran di kasir dikonfirmasi. Jika lebih dari 15 menit belum masuk, silakan hubungi dukungan kami.',
        ),
        _HelpItem(
          question: 'Apa yang dimaksud dengan Kusaku Points?',
          answer:
              '1 Kusaku Point = Rp 1. Poin dikumpulkan dari setiap transaksi menggunakan Kusaku dan bisa ditukar dengan berbagai hadiah atau digunakan melalui program Kusaku Stamp.',
        ),
        _HelpItem(
          question: 'Bagaimana cara melihat riwayat transaksi?',
          answer:
              'Kamu bisa melihat riwayat transaksi terbaru di halaman Home pada bagian "Aktivitas terbaru". Untuk riwayat lengkap, buka tab History di navbar bawah.',
        ),
        _HelpItem(
          question: 'Apa itu Kusaku Stamp?',
          answer:
              'Kusaku Stamp adalah program loyalitas berupa stamp dari merchant partner Kusaku. Kumpulkan stamp dengan bertransaksi di merchant tersebut dan tukarkan dengan hadiah atau diskon menarik. Cek stamp aktifmu di Profile → Reward → Kusaku Stamp.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text('Pusat Bantuan',
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: _sections.map((section) {
          final isExpanded = _expandedSection == section.title;
          return Column(
            children: [
              // Section header
              InkWell(
                onTap: () => setState(() =>
                    _expandedSection = isExpanded ? null : section.title),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(section.title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111827))),
                      const Icon(Icons.chevron_right,
                          color: Color(0xFF9CA3AF), size: 20),
                    ],
                  ),
                ),
              ),

              // FAQ items when expanded
              if (isExpanded)
                Container(
                  color: const Color(0xFFF9FAFB),
                  child: Column(
                    children: section.items
                        .map((item) => _FaqTile(item: item))
                        .toList(),
                  ),
                ),

              const Divider(height: 1, color: Color(0xFFE5E7EB)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final _HelpItem item;
  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(widget.item.question,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151))),
                ),
                Icon(
                  _open ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF9CA3AF),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
            child: Text(widget.item.answer,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.6)),
          ),
        const Divider(height: 1, indent: 24, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}

class _HelpSection {
  final String title;
  final List<_HelpItem> items;
  const _HelpSection({required this.title, required this.items});
}

class _HelpItem {
  final String question;
  final String answer;
  const _HelpItem({required this.question, required this.answer});
}