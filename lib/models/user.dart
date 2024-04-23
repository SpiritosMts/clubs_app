



import 'dart:convert';



class ScUser {


  //personal
  String id;
  String email;
  String name ;
  String pwd;
  String phone;
  String address;
  String role;
  String deviceToken;

  bool haveAccess;
  bool isAdmin;
  bool banned;
  bool verified;

  //time
  String joinTime;

  Map<String, dynamic> notifications;


  ScUser({
    this.id = '',
    this.email = '',
    this.name = '',
    this.pwd = '',
    this.deviceToken = '',
    this.phone = '',
    this.address = '',
    this.haveAccess = false,
    this.isAdmin = false,
    this.banned = false,
    this.joinTime = '',

    this.verified = false,
    this.notifications = const {},
    this.role = '',

  });



  // Convert ScUser object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'pwd': pwd,
      'phone': phone,
      'deviceToken': deviceToken,
      'address': address,
      'accepted': haveAccess,
      'isAdmin': isAdmin,
      'banned': banned,
      'verified': verified,
      //'cords': cords,
      'joinTime': joinTime,
      'notifications': notifications,
      'role': role,
    };
  }

  // Create ScUser object from JSON
  factory ScUser.fromJson(Map<String, dynamic> json) {
    return ScUser(

      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      pwd: json['pwd'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      deviceToken: json['deviceToken'] ?? '',
      haveAccess: json['haveAccess'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
      banned: json['banned'] ?? false,
      verified: json['verified'] ?? false,


      //cords: json['cords'] ?? const GeoPoint(0.0, 0.0),
      joinTime: json['joinTime'] ?? '',

      notifications: json['notifications'] ?? {},
      role: json['role'] ?? '',
    );
  }
}
