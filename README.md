# QR Studio - Flutter QR Code Generator

A professional, feature-rich QR code generator built with Flutter. Create print-ready QR codes with multiple templates, customization options, quality scoring, and PNG export.

## Features

### QR Code Templates
- **URL** - Generate QR codes for websites
- **Text** - Plain text encoding
- **Email** - Create mailto: links with subject and body
- **Phone** - Direct phone number dialing
- **SMS** - Pre-filled text messages
- **WiFi** - WiFi network sharing
- **Location** - Geographic coordinates
- **vCard** - Contact card format
- **MeCard** - Alternate contact format
- **Event** - Calendar event details
- **Bitcoin** - Cryptocurrency addresses
- **Social Links** - WhatsApp, Telegram, LinkedIn, Facebook, Instagram, Twitter, YouTube, GitHub

### Design Customization
- **QR Size** - Adjustable from 160px to 1000px
- **Pattern Detail** - Control QR complexity (25%, 50%, 75%, 100%)
- **Dot Style** - Choose from Square, Circle, Diamond, or Rounded styles
- **Dot Fill** - Adjust fill density (55%, 90%, 100%)

### Quality Features
- **Real-time Quality Scoring** - Scanability percentage (0-100%)
- **Smart Evaluation** - Content length, pattern detail, size analysis
- **Advisory Warnings** - Alerts for risky configurations
- **Download Protection** - Confirmation dialog for low-quality codes

### Export
- **PNG Download** - Export generated QR codes as PNG images
- **High Resolution** - Full control over output size
- **Responsive Preview** - Consistent preview while maintaining export quality

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd qr_gen
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# Mobile (iOS/Android)
flutter run

# Web
flutter run -d web

# Desktop (Windows/Linux/macOS)
flutter run -d windows
flutter run -d linux
flutter run -d macos
```

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/
│   ├── qr_type.dart        # QR type enum and value generation
│   └── qr_config.dart       # QR configuration and styling
├── screens/
│   └── home_screen.dart     # Main UI screen
├── widgets/
│   ├── qr_type_selector.dart    # Category tab selector
│   ├── qr_content_input.dart    # Form inputs for QR content
│   ├── qr_customization.dart    # Design controls
│   ├── qr_preview.dart          # QR preview display
│   └── quality_indicator.dart   # Quality score display
└── utils/
    ├── qr_quality_evaluator.dart # Quality assessment logic
    └── qr_exporter.dart          # PNG export functionality
```

## Dependencies

- **qr_flutter** (4.1.0) - QR code generation and display
- **path_provider** (2.1.0) - File system access
- **permission_handler** (11.4.4) - File permissions
- **image** (4.1.0) - Image manipulation
- **uuid** (4.0.0) - Unique ID generation
- **intl** (0.19.0) - Internationalization support

## Usage

1. **Select QR Type** - Choose from the category tabs (URL, Email, Phone, etc.)
2. **Enter Content** - Fill in the required fields for the selected type
3. **Customize Design** - Adjust size, pattern detail, dot style, and fill
4. **Generate QR** - Click "Generate QR" button
5. **Review Quality** - Check the quality score and warnings
6. **Download** - Export as PNG (with optional confirmation for low-quality codes)

## Quality Scoring

The quality evaluator assesses:
- Content length (large content reduces scanability)
- Pattern detail level
- QR code size
- Dot fill density
- Dot style complexity

Scores are categorized as:
- **Excellent (85-100%)** - Ready for production
- **Good (70-84%)** - Should scan reliably
- **Fair (50-69%)** - May have scanning issues
- **Poor (0-49%)** - Not recommended

## Configuration

Edit `lib/models/qr_config.dart` to adjust default settings:

```dart
QRConfig(
  size: 320,              // Default size in pixels
  patternDetail: 100,     // Pattern complexity percentage
  dotStyle: DotStyle.square,
  dotFill: DotFill.fill100,
)
```

## Flutter Versions

Tested and compatible with:
- Flutter 3.0.0 and above
- Dart 3.0.0 and above

## Building for Release

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Windows
```bash
flutter build windows --release
```

### Linux
```bash
flutter build linux --release
```

### macOS
```bash
flutter build macos --release
```

## Troubleshooting

### Issue: QR code generation fails
- Ensure all required fields are filled
- Check that content doesn't exceed reasonable limits
- Try generating with default settings

### Issue: Download doesn't work
- Verify file permissions are granted
- Check that storage space is available
- Try clearing app cache

### Issue: Quality score is low
- Increase QR code size
- Increase pattern detail
- Use higher dot fill density
- Reduce content length

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

## License

This project is open source and available under the MIT License.

## Author

Built as a Flutter implementation of the QR Code Generator web app.

## References

- Original Web Version: https://github.com/jaynirmal248/qr-code-generator
- Live Demo: https://jaynirmal248.github.io/qr-code-generator/
- QR Flutter Package: https://pub.dev/packages/qr_flutter

## Support

For issues and questions, please open an issue on the GitHub repository.
