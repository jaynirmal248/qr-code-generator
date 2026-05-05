import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_studio/models/qr_config.dart';
import 'package:qr_studio/models/qr_type.dart';
import 'package:qr_studio/utils/qr_exporter.dart';
import 'package:qr_studio/utils/qr_quality_evaluator.dart';
import 'package:qr_studio/widgets/qr_content_input.dart';
import 'package:qr_studio/widgets/qr_customization.dart';
import 'package:qr_studio/widgets/qr_preview.dart';
import 'package:qr_studio/widgets/qr_type_selector.dart';
import 'package:qr_studio/widgets/quality_indicator.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _qrImageKey = GlobalKey();
  QRType selectedType = QRType.url;
  QRConfig config = QRConfig();
  Map<String, String> contentFields = {};
  String generatedQRValue = '';
  QRQuality? quality;
  late ScrollController _mainScrollController;

  @override
  void initState() {
    super.initState();
    _mainScrollController = ScrollController();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: _buildAppBar(),
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade600, Colors.indigo.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QR Studio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Professional Generator',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Tooltip(
            message: 'Clear all fields',
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _clearForm,
              tooltip: 'Reset',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      controller: _mainScrollController,
      child: Column(
        children: [
          // Hero section
          _buildHeroSection(),
          const SizedBox(height: 24),

          // Type Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Type',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                QRTypeSelector(
                  selectedType: selectedType,
                  onTypeChanged: (type) {
                    setState(() {
                      selectedType = type;
                      contentFields = {};
                      generatedQRValue = '';
                      quality = null;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Content section
          _buildContentSection(),
          const SizedBox(height: 28),

          // Customization section
          _buildCustomizationSection(),
          const SizedBox(height: 28),

          // Preview section
          _buildPreviewSection(),
          const SizedBox(height: 28),

          // Quality indicator
          if (quality != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QualityIndicator(
                quality: quality!,
                showDetails: true,
              ),
            ),
          const SizedBox(height: 28),

          // Action buttons
          _buildActionButtons(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      controller: _mainScrollController,
      child: Column(
        children: [
          _buildHeroSection(),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Panel
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        QRTypeSelector(
                          selectedType: selectedType,
                          onTypeChanged: (type) {
                            setState(() {
                              selectedType = type;
                              contentFields = {};
                              generatedQRValue = '';
                              quality = null;
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                        _buildContentSection(),
                        const SizedBox(height: 32),
                        _buildCustomizationSection(),
                        const SizedBox(height: 32),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                // Right Panel
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildPreviewSection(),
                      const SizedBox(height: 24),
                      if (quality != null)
                        QualityIndicator(
                          quality: quality!,
                          showDetails: true,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade900,
            Colors.blue.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PRO VERSION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Create Studio\nQuality QR Codes',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Customize colors, shapes, and export in high resolution for print.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return _buildSectionCard(
      title: 'Content',
      child: QRContentInput(
        qrType: selectedType,
        onContentChanged: (fields) {
          setState(() {
            contentFields = fields;
            generatedQRValue = '';
            quality = null;
          });
        },
      ),
    );
  }

  Widget _buildCustomizationSection() {
    return _buildSectionCard(
      title: 'Customize',
      child: QRCustomization(
        config: config,
        onConfigChanged: (newConfig) {
          setState(() {
            config = newConfig;
            if (generatedQRValue.isNotEmpty) {
              quality = QRQualityEvaluator.evaluateQuality(
                generatedQRValue,
                newConfig,
              );
            }
          });
        },
      ),
    );
  }

  Widget _buildPreviewSection() {
    return _buildSectionCard(
      title: 'Preview',
      child: RepaintBoundary(
        child: QRPreview(
          qrValue: generatedQRValue,
          config: config,
          showPreview: generatedQRValue.isNotEmpty,
          qrImageKey: _qrImageKey,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: isMobile
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _generateQRCode,
                        icon: const Icon(Icons.flash_on_rounded),
                        label: const Text('Generate QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _clearForm,
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Clear'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: generatedQRValue.isEmpty ? null : _downloadQRCode,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: generatedQRValue.isEmpty ? null : _shareQRCode,
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share QR Code'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade200, width: 1.5),
                      foregroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateQRCode,
                    icon: const Icon(Icons.flash_on_rounded),
                    label: const Text('Generate QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: generatedQRValue.isEmpty ? null : _downloadQRCode,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: generatedQRValue.isEmpty ? null : _shareQRCode,
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade200, width: 1.5),
                      foregroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearForm,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Clear'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _generateQRCode() {
    final qrValue = selectedType.generateQRValue(contentFields);
    if (qrValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in the required fields'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      generatedQRValue = qrValue;
      quality = QRQualityEvaluator.evaluateQuality(qrValue, config);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✓ QR code generated successfully'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );

    // Scroll to preview on mobile
    if (MediaQuery.of(context).size.width < 900) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _mainScrollController.animateTo(
          _mainScrollController.position.maxScrollExtent * 0.6,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _clearForm() {
    setState(() {
      selectedType = QRType.url;
      config = QRConfig();
      contentFields = {};
      generatedQRValue = '';
      quality = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All fields cleared'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  Future<Uint8List> _captureQRCodeBytes() async {
    await WidgetsBinding.instance.endOfFrame;

    final boundary = _qrImageKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('QR code is not ready yet');
    }

    final pixelRatio = config.size / config.previewSize;
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to generate QR code image');
    }

    return byteData.buffer.asUint8List();
  }

  Future<void> _downloadQRCode() async {
    if (generatedQRValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please generate a QR code first'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    try {
      final bytes = await _captureQRCodeBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'qr_code_$timestamp.png';

      final savedPath = await QRExporter.exportQRCodeAsPNG(
        bytes,
        filename.replaceAll('.png', ''),
      );
      if (savedPath == null) {
        throw Exception('Failed to save QR code');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓ QR code saved to Downloads'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading QR code: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _shareQRCode() async {
    if (generatedQRValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please generate a QR code first'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    try {
      final bytes = await _captureQRCodeBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'qr_code_$timestamp.png';
      final shared = await QRExporter.shareQRCodeAsPNG(
        bytes,
        filename.replaceAll('.png', ''),
      );

      if (!shared) {
        throw Exception('Failed to open share sheet');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing QR code: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
