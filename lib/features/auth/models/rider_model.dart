class RiderModel {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String status;
  final bool isActive;
  final int currentTeamId;

  RiderModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.status,
    required this.isActive,
    required this.currentTeamId,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) => RiderModel(
        id: json['id'],
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phoneNumber: json['phone_number'] ?? '',
        status: json['status'] ?? 'offline',
        isActive: json['is_active'] == 1 || json['is_active'] == true,
        currentTeamId: json['current_team_id'] ?? 0,
      );
}
