class AddressEntry {
  final String id;
  final String name;
  final String address;

  AddressEntry({
    required this.id,
    required this.name,
    required this.address,
  });

  factory AddressEntry.fromJson(Map<String, dynamic> json) => AddressEntry(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
  };
}