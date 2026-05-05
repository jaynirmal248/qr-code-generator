import 'package:flutter/material.dart';
import 'package:qr_studio/models/qr_config.dart';

class QRCustomization extends StatelessWidget {
  final QRConfig config;
  final Function(QRConfig) onConfigChanged;

  const QRCustomization({
    Key? key,
    required this.config,
    required this.onConfigChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // QR Size Slider
        _buildCustomizationGroup(
          context,
          title: 'Size',
          subtitle: '${config.size}px',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: config.size.toDouble(),
                min: 160,
                max: 1000,
                divisions: 84,
                activeColor: Colors.blue,
                onChanged: (value) {
                  onConfigChanged(config.copyWith(size: value.toInt()));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Small',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      'Large',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Pattern Detail
        _buildCustomizationGroup(
          context,
          title: 'Pattern Detail',
          subtitle: '${config.patternDetail}%',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: config.patternDetail.toDouble(),
                min: 25,
                max: 100,
                divisions: 3,
                activeColor: Colors.blue,
                onChanged: (value) {
                  onConfigChanged(
                    config.copyWith(patternDetail: value.toInt()),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Wrap(
                  spacing: 12,
                  children: [
                    for (final detail in [25, 50, 75, 100])
                      GestureDetector(
                        onTap: () {
                          onConfigChanged(
                            config.copyWith(patternDetail: detail),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: config.patternDetail == detail
                                ? Colors.blue
                                : Colors.grey.shade100,
                            border: Border.all(
                              color: config.patternDetail == detail
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$detail%',
                            style: TextStyle(
                              color: config.patternDetail == detail
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: config.patternDetail == detail
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 12,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Dot Style
        _buildCustomizationGroup(
          context,
          title: 'Dot Style',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final style in DotStyle.values)
                GestureDetector(
                  onTap: () {
                    onConfigChanged(config.copyWith(dotStyle: style));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: config.dotStyle == style
                          ? Colors.blue
                          : Colors.grey.shade100,
                      border: Border.all(
                        color: config.dotStyle == style
                            ? Colors.blue
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: config.dotStyle == style
                          ? [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : [],
                    ),
                    child: Text(
                      style.label,
                      style: TextStyle(
                        color: config.dotStyle == style
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: config.dotStyle == style
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Dot Fill
        _buildCustomizationGroup(
          context,
          title: 'Dot Fill',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final fill in DotFill.values)
                GestureDetector(
                  onTap: () {
                    onConfigChanged(config.copyWith(dotFill: fill));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: config.dotFill == fill
                          ? Colors.blue
                          : Colors.grey.shade100,
                      border: Border.all(
                        color: config.dotFill == fill
                            ? Colors.blue
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: config.dotFill == fill
                          ? [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : [],
                    ),
                    child: Text(
                      fill.label,
                      style: TextStyle(
                        color: config.dotFill == fill
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: config.dotFill == fill
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Foreground Color
        _buildCustomizationGroup(
          context,
          title: 'QR Color',
          child: _buildColorPalette(
            selectedColor: config.foregroundColor,
            onColorSelected: (color) {
              onConfigChanged(config.copyWith(foregroundColor: color));
            },
          ),
        ),
        const SizedBox(height: 24),

        // Background Color
        _buildCustomizationGroup(
          context,
          title: 'Background Color',
          child: _buildColorPalette(
            selectedColor: config.backgroundColor,
            onColorSelected: (color) {
              onConfigChanged(config.copyWith(backgroundColor: color));
            },
            includeWhite: true,
          ),
        ),
      ],
    );
  }

  Widget _buildColorPalette({
    required Color selectedColor,
    required Function(Color) onColorSelected,
    bool includeWhite = false,
  }) {
    final colors = [
      if (includeWhite) Colors.white,
      Colors.black,
      Colors.blue.shade800,
      Colors.red.shade800,
      Colors.green.shade800,
      Colors.orange.shade800,
      Colors.purple.shade800,
      Colors.teal.shade800,
      Colors.pink.shade800,
      Colors.indigo.shade800,
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        final isSelected = selectedColor == color;
        final isWhite = color == Colors.white;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected 
                    ? (isWhite ? Colors.blue : Colors.blue.shade300)
                    : (isWhite ? Colors.grey.shade300 : Colors.transparent),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: isWhite ? Colors.blue : Colors.white,
                    size: 20,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomizationGroup(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
            if (subtitle != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
