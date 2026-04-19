class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? profileImageUrl;

  UserModel({required this.id, required this.name, required this.phone, this.email, this.profileImageUrl});
}
