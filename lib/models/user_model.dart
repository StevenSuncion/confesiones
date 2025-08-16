class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final List<String> photoUrls;
  final int? age;
  final String? city;
  final String? occupation;
  final String? career;
  final String? university;
  final DateTime createdAt;
  final bool isProfileComplete;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    this.photoUrls = const [],
    this.age,
    this.city,
    this.occupation,
    this.career,
    this.university,
    required this.createdAt,
    this.isProfileComplete = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      age: map['age'],
      city: map['city'],
      occupation: map['occupation'],
      career: map['career'],
      university: map['university'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isProfileComplete: map['isProfileComplete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageUrl': profileImageUrl,
      'photoUrls': photoUrls,
      'age': age,
      'city': city,
      'occupation': occupation,
      'career': career,
      'university': university,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isProfileComplete': isProfileComplete,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    List<String>? photoUrls,
    int? age,
    String? city,
    String? occupation,
    String? career,
    String? university,
    DateTime? createdAt,
    bool? isProfileComplete,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      photoUrls: photoUrls ?? this.photoUrls,
      age: age ?? this.age,
      city: city ?? this.city,
      occupation: occupation ?? this.occupation,
      career: career ?? this.career,
      university: university ?? this.university,
      createdAt: createdAt ?? this.createdAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}

class ConfessionModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String? textContent;
  final String? audioUrl;
  final DateTime createdAt;
  final bool isRevealed;

  ConfessionModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    this.textContent,
    this.audioUrl,
    required this.createdAt,
    this.isRevealed = false,
  });

  factory ConfessionModel.fromMap(Map<String, dynamic> map) {
    return ConfessionModel(
      id: map['id'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      textContent: map['textContent'],
      audioUrl: map['audioUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isRevealed: map['isRevealed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'textContent': textContent,
      'audioUrl': audioUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRevealed': isRevealed,
    };
  }
}