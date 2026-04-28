import 'package:flutter/material.dart';

class SyaratKetentuanPage extends StatelessWidget {
  const SyaratKetentuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text(
          'Syarat dan Ketentuan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: _TermsContent(),
      ),
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SectionTitle(
          '[Terakhir diperbarui: 19 Februari 2026]\n',
        ),
        _Subtitle(
          'Selamat datang di aplikasi Kusaku. Syarat dan Ketentuan ini mengatur penggunaan layanan dompet digital (e-wallet) yang disediakan oleh Kusaku. Dengan mengakses atau menggunakan aplikasi Kusaku, pengguna dianggap telah membaca, memahami, dan menyetujui seluruh isi Syarat dan Ketentuan ini.',
        ),

        _SectionTitle(
          '1. Definisi:',
        ),
        _Body(
          '∘ Aplikasi Kusaku: Platform dompet digital yang digunakan untuk melakukan transaksi elektronik.\n∘ Pengguna: Individu yang mendaftar dan menggunakan layanan Kusaku.\n∘ Saldo Kusaku: Nilai uang elektronik yang tersimpan dalam akun pengguna.\n∘ Transaksi: Aktivitas pembayaran, transfer, top-up, atau layanan lain yang tersedia pada aplikasi.',
        ),

        _SectionTitle(
          '2. Persyaratan Pengunaan:',
        ),
        _Subtitle(
          'Untuk menggunakan Kusaku, pengguna hrus:',
        ),
        _Body(
          '∘ Berusia minimal 17 tahun atau telah memiliki identitas resmi\n∘ Memberikan data yang benar, lengkap, dan terbaru\n∘ Menjaga kerahasiaan akun, PIN, dan kode OTP\n∘ Tidak menggunakan aplikasi untuk aktivitas ilegal\n∘ Kami berhak menolak atau menonaktifkan akun jika ditemukan pelanggaran.',
        ),

        _SectionTitle(
          '3. Pendaftaran dan Keamanan Akun:',
        ),
        _Body(
          '∘ Pengguna wajib melakukan proses registrasi dengan nomor telepon aktif.\n∘ Pengguna bertanggung jawab atas seluruh aktivitas yang terjadi pada akun.\n∘ Kusaku tidak bertanggung jawab atas kerugian akibat kelalaian pengguna dalam menjaga keamanan akun.',
        ),

        _SectionTitle(
          '4. Penggunaan Layanan:',
        ),
        _Subtitle(
          'Layanan Kusaku Meliputi:',
        ),
        _Body(
          '∘ Top-up saldo\n∘ Pembayaran digital\n∘ Transfer antar pengguna\n∘ Pembayaran merchant (jika tersedia)',
        ),

        _SectionTitle(
          '5. Saldo dan Transaksi:',
        ),
        _Body(
          '∘ Saldo Kusaku bukan merupakan simpanan bank.\n∘ Pengguna bertanggung jawab memastikan saldo mencukupi sebelum transaksi.\n∘ Kusaku berhak menetapkan batas minimum dan maksimum transaksi.',
        ),

        _SectionTitle(
          '6. Biaya Layanan:',
        ),
        _Subtitle(
          'Kusaku dapat mengenakan biaya layanan pada fitur tertentu, seperti:',
        ),
        _Body(
          '∘ Transfer bank\n∘ Penarikan saldo\n∘ Top-up melalui metode tertentu',
        ),
        _Subtitle(
          'Besaran biaya akan ditampilkan sebelum transaksi dilakukan',
        ),

        _SectionTitle(
          '7. Larangan Penggunaan:',
        ),
        _Subtitle(
          'Pengguna dilarang:',
        ),
        _Body(
          '∘ Menggunakan aplikasi untuk pencucian uang\n∘ Melakukan penipuan atau transaksi ilegal\n∘ Mengakses sistem secara tidak sah\n∘ Menyalahgunakan bug atau kesalahan system',
        ),
        _Subtitle(
          'Pelanggaran dapat menyebabkan pembekuan akun.',
        ),

        _SectionTitle(
          '8. Pemblokiran dan Penutupan akun:',
        ),
        _Subtitle(
          'Kusaku dapat menonaktifkan akun apabila:',
        ),
        _Body(
          '∘ Ditemukan aktivitas mencurigakan\n∘ Pengguna melanggar syarat dan ketentuan\n∘ Diperlukan untuk kepentingan keamanan system',
        ),

        _SectionTitle(
          '9. Perlindungan Data Pribadi:',
        ),
        _Subtitle(
          'Penggunaan data pribadi mengacu pada Kebijakan Privasi Kusaku. Kami berkomitmen menjaga keamanan data pengguna sesuai peraturan yang berlaku.',
        ),

        _SectionTitle(
          '10. Perubahan Layanan:',
        ),
        _Subtitle(
          'Kusaku dapat:',
        ),
        _Body(
          '∘ Mengubah fitur layanan\n∘ Menambah atau menghapus fitur\n∘ Memperbarui sistem keamanan',
        ),
        _Subtitle(
          'Perubahan akan diinformasikan melalui aplikasi.',
        ),

        _SectionTitle(
          '11. Batasan Tanggung Jawab:',
        ),
        _Subtitle(
          'Kusaku tidak bertanggung jawab atas:',
        ),
        _Body(
          '∘ Gangguan layanan akibat jaringan internet\n∘ Kerugian akibat kesalahan input pengguna\n∘ Penyalahgunaan akun oleh pihak lain karena kelalaian pengguna',
        ),

        _SectionTitle(
          '12. Hukum yang Berlaku:',
        ),
        _Subtitle(
          'Syarat dan Ketentuan ini diatur berdasarkan hukum yang berlaku di Republik Indonesia.',
        ),

        _SectionTitle(
          '13. Kontak Layanan:',
        ),
        _Subtitle(
          'Jika terdapat pertanyaan atau keluhan, pengguna dapat menghubungi:',
        ),
        _Emailstuff('Email:'), _Body('[support@Kusaku.com]'),
        _Emailstuff('Layanan Pelanggan:'), _Body('[Insert nanti]'),

        _SectionTitle(
          '14. Persetujuan Pengguna:',
        ),
        _Subtitle(
          'Dengan menggunakan aplikasi Kusaku, pengguna menyatakan telah membaca dan menyetujui seluruh Syarat dan Ketentuan ini.',
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w700,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  final String text;
  const _Subtitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color.fromARGB(255, 83, 83, 83),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 13,
          color: Color.fromARGB(255, 81, 90, 102),
          height: 1.6,
        ),
      ),
    );
  }
}

class _Emailstuff extends StatelessWidget {
  final String text;
  const _Emailstuff(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
       child: Text(
        text,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color.fromARGB(255, 63, 63, 63),
          height: 1.6,
        ),
      ),
    );
  }
}