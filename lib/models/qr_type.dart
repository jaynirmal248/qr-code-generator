enum QRType {
  url('URL', 'https://example.com'),
  text('Text', 'Enter text here'),
  email('Email', 'name@example.com'),
  phone('Phone', '+1 (555) 123-4567'),
  sms('SMS', '+1 (555) 123-4567'),
  wifi('WiFi', ''),
  location('Location', ''),
  vcard('vCard', ''),
  mecard('MeCard', ''),
  event('Event', ''),
  bitcoin('Bitcoin', 'bc1...'),
  whatsapp('WhatsApp', '+1 (555) 123-4567'),
  telegram('Telegram', '@username'),
  linkedin('LinkedIn', 'linkedin.com/in/...'),
  facebook('Facebook', 'facebook.com/...'),
  instagram('Instagram', '@username'),
  twitter('Twitter', '@username'),
  youtube('YouTube', 'youtube.com/@username'),
  github('GitHub', 'github.com/username');

  final String label;
  final String placeholder;

  const QRType(this.label, this.placeholder);

  String generateQRValue(Map<String, String> fields) {
    switch (this) {
      case QRType.url:
        return fields['url'] ?? '';
      case QRType.text:
        return fields['text'] ?? '';
      case QRType.email:
        final email = fields['email'] ?? '';
        final subject = fields['subject'] ?? '';
        final body = fields['body'] ?? '';
        if (email.isEmpty) return '';
        return 'mailto:$email${subject.isNotEmpty || body.isNotEmpty ? '?' : ''}${subject.isNotEmpty ? 'subject=$subject' : ''}${body.isNotEmpty ? (subject.isNotEmpty ? '&' : '') + 'body=$body' : ''}';
      case QRType.phone:
        return 'tel:${fields['phone'] ?? ''}';
      case QRType.sms:
        final phone = fields['phone'] ?? '';
        final message = fields['message'] ?? '';
        return 'smsto:$phone${message.isNotEmpty ? '?body=$message' : ''}';
      case QRType.wifi:
        final ssid = fields['ssid'] ?? '';
        final password = fields['password'] ?? '';
        final security = fields['security'] ?? 'WPA';
        return 'WIFI:T:$security;S:$ssid;P:$password;;';
      case QRType.location:
        final lat = fields['latitude'] ?? '';
        final lng = fields['longitude'] ?? '';
        return 'geo:$lat,$lng';
      case QRType.vcard:
        final name = fields['name'] ?? '';
        final phone = fields['phone'] ?? '';
        final email = fields['email'] ?? '';
        final org = fields['organization'] ?? '';
        return 'BEGIN:VCARD\nVERSION:3.0\nFN:$name\nTEL:$phone\nEMAIL:$email\nORG:$org\nEND:VCARD';
      case QRType.mecard:
        final name = fields['name'] ?? '';
        final phone = fields['phone'] ?? '';
        final email = fields['email'] ?? '';
        return 'MECARD:N:$name;TEL:$phone;EMAIL:$email;;';
      case QRType.event:
        final title = fields['title'] ?? '';
        final description = fields['description'] ?? '';
        final startDate = fields['startDate'] ?? '';
        final endDate = fields['endDate'] ?? '';
        return 'BEGIN:VEVENT\nSUMMARY:$title\nDESCRIPTION:$description\nDTSTART:$startDate\nDTEND:$endDate\nEND:VEVENT';
      case QRType.bitcoin:
        return 'bitcoin:${fields['address'] ?? ''}';
      case QRType.whatsapp:
        final phone = fields['phone'] ?? '';
        final message = fields['message'] ?? '';
        return 'https://wa.me/$phone${message.isNotEmpty ? '?text=$message' : ''}';
      case QRType.telegram:
        return 'https://t.me/${fields['username'] ?? ''}';
      case QRType.linkedin:
        return 'https://linkedin.com/in/${fields['username'] ?? ''}';
      case QRType.facebook:
        return 'https://facebook.com/${fields['username'] ?? ''}';
      case QRType.instagram:
        return 'https://instagram.com/${fields['username'] ?? ''}';
      case QRType.twitter:
        return 'https://twitter.com/${fields['username'] ?? ''}';
      case QRType.youtube:
        return 'https://youtube.com/@${fields['username'] ?? ''}';
      case QRType.github:
        return 'https://github.com/${fields['username'] ?? ''}';
    }
  }
}
