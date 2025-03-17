class Admin {
  final int adminID;
  final String name, email, password, privilege;

  Admin(
      {required this.adminID,
      required this.name,
      required this.email,
      required this.password,
      required this.privilege});

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      name: json['AdminName'],
      email: json['Email'],
      password: json['Password'],
      privilege: json['Privileges'],
      adminID: json['AdminID'],
    );
  }
}
