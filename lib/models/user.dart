



import 'dart:convert';



class ScUser {


  //personal
  String id;
  String email;
  String name ;
  String pwd;
  String phone;
  String address;
  String deviceToken;
  bool isAdmin;

  //time
  String joinTime;



  ScUser({
    this.id = '',
    this.email = '',
    this.name = '',
    this.pwd = '',
    this.phone = '',
    this.address = '',
    this.deviceToken = '',
    this.isAdmin = false,
    this.joinTime = '',

  });



  // Convert ScUser object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'pwd': pwd,
      'deviceToken': deviceToken,
      'phone': phone,
      'address': address,
      'isAdmin': isAdmin,
      //'cords': cords,
      'joinTime': joinTime,
    };
  }

  // Create ScUser object from JSON
  factory ScUser.fromJson(Map<String, dynamic> json) {
    return ScUser(

      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      pwd: json['pwd'] ?? '',
      deviceToken: json['deviceToken'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      //cords: json['cords'] ?? const GeoPoint(0.0, 0.0),
      joinTime: json['joinTime'] ?? '',
    );
  }
}
