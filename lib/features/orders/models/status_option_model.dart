class StatusOption {
  final int id;
  final String name;
  final String? description;
  final String color;

  StatusOption({
    required this.id,
    required this.name,
    this.description,
    required this.color,
  });  
  // "warehouse_id": 1,


  factory StatusOption.fromJson(Map<String, dynamic> json) {
    return StatusOption(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: json['color'] ?? 'gray',
    );
  }
}