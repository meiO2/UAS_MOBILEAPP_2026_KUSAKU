import 'package:flutter/material.dart';

class PanduanKusakuPage extends StatefulWidget {
  const PanduanKusakuPage({super.key});

  @override
  State<PanduanKusakuPage> createState() => _PanduanKusakuPageState();
}

class _PanduanKusakuPageState extends State<PanduanKusakuPage> {
  String? _expandedSection;

  final List<_GuideSection> _sections = [
    _GuideSection(
      title: 'Cara Pakai A.I Kusaku',
      steps: [
        _GuideStep(
          number: 1,
          description: 'Tekan "Finance" di halaman home',
          imagePath: 'images/keuntungan/kelola1.png',
        ),
        _GuideStep(
          number: 2,
          description: 'Tekan Logo SI PINTAR',
          imagePath: 'images/keuntungan/kelola2.png',
        ),
        _GuideStep(
          number: 3,
          description: 'Beri Prompt sesuai kebutuhanmu',
          imagePath: 'images/keuntungan/kelola3.png',
        ),
      ],
    ),
    _GuideSection(
      title: 'Kusaku Stamp',
      steps: [
        _GuideStep(
          number: 1,
          description: 'Lakukan transaksi untuk mendapatkan Kusaku Points',
          imagePath: 'images/panduan/panduan1.png',
        ),
        _GuideStep(
          number: 2,
          description: 'Tekan “Profile” di halaman home',
          imagePath: 'images/panduan/panduan2.png',
        ),
        _GuideStep(
          number: 3,
          description: 'Cek Point dan Klaim kupon',
          imagePath: 'images/panduan/panduan3.png',
        ),
        _GuideStep(
          number: 4,
          description: 'Setiap Min. Rp 1.000 akan mendapatkan 10 Kusaku Points',
          imagePath: 'images/panduan/panduan4.png',
        ),
        _GuideStep(
          number: 5,
          description: 'Klaim Kupon Mu',
          imagePath: 'images/panduan/panduan5.png',
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
        title: const Text(
          'Panduan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page title ──
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                'Pakai Kusaku semua jadi mudah',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),

            // ── Sections ──
            ...(_sections.map((section) => _ExpandableSection(
                  section: section,
                  isExpanded: _expandedSection == section.title,
                  onTap: () {
                    setState(() {
                      _expandedSection =
                          _expandedSection == section.title ? null : section.title;
                    });
                  },
                ))),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Expandable section ──
class _ExpandableSection extends StatelessWidget {
  final _GuideSection section;
  final bool isExpanded;
  final VoidCallback onTap;

  const _ExpandableSection({
    required this.section,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section header row
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            color: isExpanded ? const Color(0xFFECFDF5) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              section.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isExpanded ? FontWeight.w600 : FontWeight.w400,
                color: isExpanded ? const Color(0xFF065F46) : const Color(0xFF374151),
              ),
            ),
          ),
        ),

        // Expanded steps
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: section.steps
                  .map((step) => _StepCard(step: step))
                  .toList(),
            ),
          ),

        const Divider(height: 1, thickness: 0.5, color: Color.fromARGB(255, 255, 255, 255)),
      ],
    );
  }
}

// ── Individual step card ──
class _StepCard extends StatelessWidget {
  final _GuideStep step;

  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step number badge + description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${step.number}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      step.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Image placeholder
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  step.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Shows a clean placeholder when image isn't added yet
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined,
                            size: 36, color: const Color.fromARGB(255, 255, 255, 255)),
                        const SizedBox(height: 6),
                        Text(
                          step.imagePath,
                          style: TextStyle(
                            fontSize: 10,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data models ──
class _GuideSection {
  final String title;
  final List<_GuideStep> steps;
  const _GuideSection({required this.title, required this.steps});
}

class _GuideStep {
  final int number;
  final String description;
  final String imagePath;
  const _GuideStep({
    required this.number,
    required this.description,
    required this.imagePath,
  });
}