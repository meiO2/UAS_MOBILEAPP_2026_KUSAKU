import 'package:flutter/material.dart';

class ScanColors {
  static const Color headerBlue = Color(0xFF2C469C);
  static const Color accentBlue = Color(0xFF2D5BE3);
  static const Color pageBackground = Color(0xFFF3F5FB);
  static const Color cardBorder = Color(0xFFD2D8EA);
  static const Color hintBlue = Color(0xFF0B4FB7);
  static const Color mutedText = Color(0xFF445A7A);
}

enum ScanContentType { qris, receipt }

class ScanGalleryItem {
  const ScanGalleryItem({
    required this.id,
    this.previewColor = const Color(0xFFD9D9D9),
    this.isReceipt = false,
  });

  final String id;
  final Color previewColor;
  final bool isReceipt;
}

class ScanTopBar extends StatelessWidget {
  const ScanTopBar({
    required this.title,
    required this.onBack,
    super.key,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ScanColors.headerBlue,
      padding: const EdgeInsets.fromLTRB(8, 8, 18, 18),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class ScanInstructionSection extends StatelessWidget {
  const ScanInstructionSection({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ScanColors.hintBlue,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: ScanColors.hintBlue,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class ScanPreviewFrame extends StatelessWidget {
  const ScanPreviewFrame({
    required this.contentType,
    required this.isFlashOn,
    required this.showGalleryOverlay,
    required this.previewLabel,
    super.key,
  });

  final ScanContentType contentType;
  final bool isFlashOn;
  final bool showGalleryOverlay;
  final String previewLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 24, 30, 0),
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 320),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isFlashOn ? const Color(0xFFB3B3B3) : const Color(0xFF979797),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: contentType == ScanContentType.qris
                      ? const _QrPreview(key: ValueKey('qr'))
                      : const _ReceiptPreview(key: ValueKey('receipt')),
                ),
              ),
            ),
            const _FrameCorners(),
            if (showGalleryOverlay)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    previewLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ScanGuidanceCard extends StatelessWidget {
  const ScanGuidanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(40, 28, 40, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ScanColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              color: ScanColors.accentBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pastikan kode QR terlihat jelas',
                  style: TextStyle(
                    color: ScanColors.hintBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Jarak ideal 10-20 cm',
                  style: TextStyle(
                    color: ScanColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScanActionItem {
  const ScanActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
}

class ScanActionBar extends StatelessWidget {
  const ScanActionBar({
    required this.items,
    super.key,
  });

  final List<ScanActionItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Expanded(
                child: _ScanActionButton(item: item),
              ),
            )
            .toList(),
      ),
    );
  }
}

class GalleryPickerSheet extends StatelessWidget {
  const GalleryPickerSheet({
    required this.items,
    required this.selectedId,
    required this.onSelect,
    required this.onSend,
    super.key,
  });

  final List<ScanGalleryItem> items;
  final String? selectedId;
  final ValueChanged<ScanGalleryItem> onSelect;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(child: SizedBox()),
                Container(
                  width: 164,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF232323),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: onSend,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA9C8FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Send',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 0.88,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.id == selectedId;
                return GestureDetector(
                  onTap: () => onSelect(item),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          color: item.previewColor,
                          child: item.isReceipt
                              ? const _MiniReceiptPreview()
                              : const _MiniQrPreview(),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? const Color(0xFFA9C8FF)
                                : Colors.transparent,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ScanStatusChip extends StatelessWidget {
  const ScanStatusChip({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EEFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: ScanColors.hintBlue,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ScanActionButton extends StatelessWidget {
  const _ScanActionButton({required this.item});

  final ScanActionItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: item.isActive
                  ? const Color(0xFF163DB9)
                  : ScanColors.accentBlue,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              item.icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF12316B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FrameCorners extends StatelessWidget {
  const _FrameCorners();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _FrameCornerPainter(),
        ),
      ),
    );
  }
}

class _FrameCornerPainter extends CustomPainter {
  const _FrameCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFF1B1B1B);
    const stroke = 3.0;
    const corner = 18.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke;

    void drawCorner(Offset start, Offset horizontal, Offset vertical) {
      canvas.drawLine(start, horizontal, paint);
      canvas.drawLine(start, vertical, paint);
    }

    drawCorner(const Offset(0, 0), const Offset(corner, 0), const Offset(0, corner));
    drawCorner(
      Offset(size.width, 0),
      Offset(size.width - corner, 0),
      Offset(size.width, corner),
    );
    drawCorner(
      Offset(0, size.height),
      Offset(corner, size.height),
      Offset(0, size.height - corner),
    );
    drawCorner(
      Offset(size.width, size.height),
      Offset(size.width - corner, size.height),
      Offset(size.width, size.height - corner),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QrPreview extends StatelessWidget {
  const _QrPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      height: 165,
      child: Image.asset(
        'assets/images/qris.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 220,
      child: Image.asset(
        'assets/images/nota.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class _MiniQrPreview extends StatelessWidget {
  const _MiniQrPreview();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 165,
            height: 165,
            child: _QrPreview(),
          ),
        ),
      ),
    );
  }
}

class _MiniReceiptPreview extends StatelessWidget {
  const _MiniReceiptPreview();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 52,
        height: 72,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 190,
            height: 220,
            child: _ReceiptPreview(),
          ),
        ),
      ),
    );
  }
}
