enum UserRole { coordinatorProvincial, coordinatorRecinto, observer }

class AppUser {
  final String id;
  final String email;
  final UserRole role;
  final bool mustChangePassword;

  AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.mustChangePassword,
  });
}
