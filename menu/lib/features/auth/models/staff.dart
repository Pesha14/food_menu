class Department {
  final int id;
  final String name;

  Department({required this.id, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        id: json['id'] as int,
        name: json['name'] as String,
      );
}

class Company {
  final int id;
  final String name;
  final num dailyDiscount;

  Company({required this.id, required this.name, required this.dailyDiscount});

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        id: json['id'] as int,
        name: json['name'] as String,
        dailyDiscount: json['dailyDiscount'] as num? ?? 0,
      );
}

class StaffRole {
  final int id;
  final String code;
  final String name;

  StaffRole({required this.id, required this.code, required this.name});

  factory StaffRole.fromJson(Map<String, dynamic> json) => StaffRole(
        id: json['id'] as int,
        code: json['code'] as String,
        name: json['name'] as String,
      );
}

class Staff {
  final int id;
  final String staffId;
  final String staffNumber;
  final String username;
  final String fullName;
  final String phone;
  final int status;
  final Department department;
  final Company company;
  final StaffRole role;

  Staff({
    required this.id,
    required this.staffId,
    required this.staffNumber,
    required this.username,
    required this.fullName,
    required this.phone,
    required this.status,
    required this.department,
    required this.company,
    required this.role,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        id: json['id'] as int,
        staffId: json['staffId'] as String,
        staffNumber: json['staffNumber'] as String,
        username: json['username'] as String,
        fullName: json['fullName'] as String,
        phone: json['phone'] as String? ?? '',
        status: json['status'] as int? ?? 1,
        department: Department.fromJson(
          json['department'] as Map<String, dynamic>,
        ),
        company: Company.fromJson(json['company'] as Map<String, dynamic>),
        role: StaffRole.fromJson(json['role'] as Map<String, dynamic>),
      );
}

/// Everything the app holds in memory for the duration of a shift, cleared
/// on logout as required by the integration guide.
class AuthSession {
  final String token;
  final String userType;
  final Staff staff;

  AuthSession({
    required this.token,
    required this.userType,
    required this.staff,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        token: json['token'] as String,
        userType: json['userType'] as String,
        staff: Staff.fromJson(json['staff'] as Map<String, dynamic>),
      );
}
