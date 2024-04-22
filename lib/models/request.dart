class JoinRequest {
  String id;
  String date;
  String studentName;
  String studentID;
  String clubToJoinName;
  String clubToJoinID;

  // Constructor for initializing a Request object
  JoinRequest({
    this.id = '',
    this.date = '',
    this.studentName = '',
    this.studentID = '',
    this.clubToJoinName = '',
    this.clubToJoinID = '',
  });

  // Convert Request object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'studentName': studentName,
      'studentID': studentID,
      'clubToJoinName': clubToJoinName,
      'clubToJoinID': clubToJoinID,
    };
  }

  // Create Request object from JSON
  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    return JoinRequest(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      studentName: json['studentName'] ?? '',
      studentID: json['studentID'] ?? '',
      clubToJoinName: json['clubToJoinName'] ?? '',
      clubToJoinID: json['clubToJoinID'] ?? '',
    );
  }
}
