import 'package:flutter/material.dart';
import 'package:qr_studio/models/qr_type.dart';

class QRContentInput extends StatefulWidget {
  final QRType qrType;
  final Function(Map<String, String>) onContentChanged;

  const QRContentInput({
    Key? key,
    required this.qrType,
    required this.onContentChanged,
  }) : super(key: key);

  @override
  State<QRContentInput> createState() => _QRContentInputState();
}

class _QRContentInputState extends State<QRContentInput> {
  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    controllers = {};
    final fields = _getFieldsForType(widget.qrType);
    for (final field in fields) {
      controllers[field] = TextEditingController();
    }
  }

  @override
  void didUpdateWidget(QRContentInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.qrType != widget.qrType) {
      // Clear and reinitialize controllers
      for (final controller in controllers.values) {
        controller.dispose();
      }
      _initializeControllers();
    }
  }

  List<String> _getFieldsForType(QRType type) {
    switch (type) {
      case QRType.url:
        return ['url'];
      case QRType.text:
        return ['text'];
      case QRType.email:
        return ['email', 'subject', 'body'];
      case QRType.phone:
        return ['phone'];
      case QRType.sms:
        return ['phone', 'message'];
      case QRType.wifi:
        return ['ssid', 'password', 'security'];
      case QRType.location:
        return ['latitude', 'longitude'];
      case QRType.vcard:
        return ['name', 'phone', 'email', 'organization'];
      case QRType.mecard:
        return ['name', 'phone', 'email'];
      case QRType.event:
        return ['title', 'description', 'startDate', 'endDate'];
      case QRType.bitcoin:
        return ['address'];
      case QRType.whatsapp:
        return ['phone', 'message'];
      case QRType.telegram:
      case QRType.linkedin:
      case QRType.facebook:
      case QRType.instagram:
      case QRType.twitter:
      case QRType.youtube:
      case QRType.github:
        return ['username'];
    }
  }

  String _getFieldLabel(String field) {
    final labels = {
      'url': 'Website URL',
      'text': 'Text',
      'email': 'Email Address',
      'phone': 'Phone Number',
      'message': 'Message',
      'ssid': 'Network Name (SSID)',
      'password': 'Password',
      'security': 'Security Type',
      'latitude': 'Latitude',
      'longitude': 'Longitude',
      'name': 'Name',
      'organization': 'Organization',
      'subject': 'Subject',
      'body': 'Message Body',
      'title': 'Event Title',
      'description': 'Description',
      'startDate': 'Start Date',
      'endDate': 'End Date',
      'address': 'Bitcoin Address',
      'username': 'Username',
    };
    return labels[field] ?? field;
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _notifyChanges() {
    final content = <String, String>{};
    controllers.forEach((key, controller) {
      content[key] = controller.text;
    });
    widget.onContentChanged(content);
  }

  @override
  Widget build(BuildContext context) {
    final fields = _getFieldsForType(widget.qrType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < fields.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i < fields.length - 1 ? 16 : 0),
            child: _buildTextField(
              field: fields[i],
              isLastField: i == fields.length - 1,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required String field,
    required bool isLastField,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getFieldLabel(field),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controllers[field],
          onChanged: (_) => _notifyChanges(),
          textInputAction: isLastField ? TextInputAction.done : TextInputAction.next,
          decoration: InputDecoration(
            hintText: _getHintForField(field),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            suffixIcon: controllers[field]?.text.isNotEmpty ?? false
                ? GestureDetector(
              onTap: () {
                controllers[field]?.clear();
                _notifyChanges();
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ),
            )
                : null,
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  String _getHintForField(String field) {
    final hints = {
      'url': 'https://example.com',
      'text': 'Enter your text here',
      'email': 'name@example.com',
      'phone': '+1 (555) 123-4567',
      'ssid': 'MyWiFiNetwork',
      'password': '••••••••',
      'latitude': '40.7128',
      'longitude': '-74.0060',
      'username': 'username',
      'address': 'bc1...',
      'subject': 'Email subject',
      'body': 'Message body...',
      'name': 'Full name',
      'organization': 'Organization name',
      'title': 'Event title',
      'description': 'Event description',
      'message': 'Your message',
    };
    return hints[field] ?? '';
  }
}
