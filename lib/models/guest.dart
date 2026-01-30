class Guest {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? company;
  final bool attended;
  final String qrCode;

  Guest({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.company,
    required this.attended,
    required this.qrCode,
  });

  String get name => '$firstName $lastName';

  factory Guest.fromJson(Map<String, dynamic> json) {
    // Handle fallback for legacy 'name' field if existing
    String fName = json['first_name'] ?? '';
    String lName = json['last_name'] ?? '';

    if (fName.isEmpty && lName.isEmpty && json['name'] != null) {
      final parts = (json['name'] as String).split(' ');
      fName = parts.first;
      lName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    return Guest(
      id: json['id'],
      firstName: fName,
      lastName: lName,
      email: json['email'],
      company: json['company'],
      attended: json['attended'] ?? false,
      qrCode: json['qr_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'company': company,
      'attended': attended,
      'qr_code': qrCode,
    };
  }

  Guest copyWith({bool? attended}) {
    return Guest(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      company: company,
      attended: attended ?? this.attended,
      qrCode: qrCode,
    );
  }
}
