import 'package:flutter/material.dart';

class KebijakanPrivasiPage extends StatelessWidget {
  const KebijakanPrivasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: const Text(
          'Kebijakan Privasi',
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
        child: _PrivacyContent(),
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SectionTitle('Terakhir diperbarui: [19 Februari 2026]\n'),
        _Body(
          'Aplikasi Kusaku (“Kami”) berkomitmen untuk melindungi privasi dan keamanan data pribadi pengguna (“Pengguna”). Kebijakan Privasi ini menjelaskan bagaimana Kami mengumpulkan, menggunakan, menyimpan, dan melindungi informasi Pengguna saat menggunakan layanan aplikasi e-wallet Kusaku.',
        ),
        _Body(
          'Dengan menggunakan aplikasi Kusaku, Pengguna dianggap telah membaca dan menyetujui Kebijakan Privasi ini.',
        ),

        _SectionTitle('1. Informasi yang kami kumpulkan:'),
        _SectionTitle('Kami mengumpulkan beberapa jenis informasi berikut:'),

        _Subtitle(
          'A. Informasi Pribadi',
        ),
        _Body( 
          '∘ Nama Lengkap\n∘ Alamat Email\n∘ Nomor Identitas (KTP/Passport) untuk proses verifikasi akun (KYC)\n∘ Foto Profile',
        ),

        _Subtitle(
          'B. Informasi Keuangan',
        ),
        _Body(
          '∘ Riwayat Transaksi\n∘ Saldo e-wallet\n∘ Data rekening yang terhubung (Jika ada)\n∘ Data top-up dan pembayaran',
        ),

        _Subtitle(
          'C. Informasi Perangkat',
        ),
        _Body(
          '∘ Jenis pernagkat\n∘ Sistem Operasi\n∘ Alamat IP',
        ),
        _Subtitle(
          'D. Informasi Lokasi (Opsional)',
        ),
        _Body(
          '∘ Digunakan untuk meingkatkan keamanan transaksi dan mendukung fitur layanan berbasis lokasi',
        ),

        _SectionTitle(
          '2. Cara Kami Menggunakan Informasi',
        ),
        _Subtitle(
          'Informasi yang dikumpulkan digunakan untuk:',
        ),
        _Body(
          '∘ Memproses transaksi pembayaran dan transfer\n∘ Melakukan verifikasi identitas pengguna (KYC)\n∘ Meningkatkan keamanan akun dan mencegah penipuan\n∘ Mengembangkan serta meningkatkan fitur aplikasi\n∘ Mengirim notifikasi transaksi dan informasi layanan\n∘ Memenuhi kewajiban hukum dan regulasi yang berlaku',
        ),

        _SectionTitle(
          '3. Penyimpanan dan Keamanan Data:'
        ),
        _Subtitle(
          'Kami menerapkan langkah-langkah keamanan teknis untuk melindungi data pengguna, antara lain:',
        ),
        _Body(
          '∘ Enkripsi data\n∘ Sistem autentikasi berlapis (PIN, OTP, atau biometrik)\n∘ Pembatasan akses data internal',
        ),
        _Body(
          'Data pengguna disimpan selama masih diperlukan untuk tujuan layanan serta sesuai dengan ketentuan hukum yang berlaku.',
        ),

        _SectionTitle(
          '4. Pembagian Informasi Kepada Pihak Ketiga:',
        ),
        _Subtitle(
          'Kami tidak menjual data pribadi pengguna. Namun, dalam kondisi tertentu data dapat dibagikan kepada:',
        ),
        _Body(
          '∘ Mitra bank dan penyedia layanan pembayaran\n∘ Penyedia layanan teknologi (server/cloud)\n∘ Otoritas pemerintah atau regulator jika diwajibkan oleh hukum',
        ),
        _Body(
          'Pembagian data dilakukan hanya sebatas kebutuhan layanan.',
        ),

        _SectionTitle(
          '5. Hak Pengguna:',
        ),
        _Subtitle(
          'Pengguna memiliki hak untuk:',
        ),
        _Body(
          '∘ Mengakses data pribadi\n∘ Memperbarui informasi akun\n∘ Meminta penghapusan data (sesuai ketentuan hukum)\n∘ Menonaktifkan akun',
        ),
        _Body(
          'Permintaan dapat diajukan melalui kontak resmi aplikasi Kusaku.',
        ),

        _SectionTitle(
          '6. Cookies dan Teknologi Pelacakan:',
        ),
        _Subtitle(
          'Aplikasi Kusaku dapat menggunakan cookies atau teknologi serupa untuk:',
        ),
        _Body(
          '∘ Menyimpan preferensi pengguna\n∘ Analisis penggunaan aplikasi\n∘ Meningkatkan pengalaman pengguna',
        ),

        _SectionTitle(
          '7. Perubahan Kebijakan Privasi:',
        ),
        _Subtitle(
          'Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Setiap perubahan akan diumumkan melalui aplikasi Kusaku.',
        ),
        
        _SectionTitle(
          '8. Kontak Kami:',
        ),
        _Subtitle(
          'Jika terdapat pertanyaan mengenai kebijakan privasi ini, silahkan hubungi:',
        ),
        _Emailstuff('Email:'), _Body('[support@Kusaku.com]'),
        _Emailstuff('Alamat:'), _Body('[Insert nanti]'),

        _SectionTitle(
          '9. Persetujuan Pengguna:',
        ),
        _Subtitle(
          'Dengan menggunakan aplikasi Kusaku, pengguna menyatakan telah membaca, memahami, dan menyetujui Kebijakan Privasi ini.',
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