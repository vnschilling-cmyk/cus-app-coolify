class Guest {
  final String id;
  final String name;
  final String? company;
  final bool attended;
  final String qrCode;

  Guest({
    required this.id,
    required this.name,
    this.company,
    required this.attended,
    required this.qrCode,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      name: json['name'],
      company: json['company'],
      attended: json['attended'] ?? false,
      qrCode: json['qr_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company': company,
      'attended': attended,
      'qr_code': qrCode,
    };
  }

  Guest copyWith({bool? attended}) {
    return Guest(
      id: id,
      name: name,
      company: company,
      attended: attended ?? this.attended,
      qrCode: qrCode,
    );
  }
}
