// Author: `Gilyazeev Adel` (@Atom735)
// Created Date: `2023-10-16`

import 'package:meta/meta.dart';

@immutable
class UserData {
  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String password;
  final String loginType;
  final String googleId;
  final String profilePic;
  final String coverPic;
  final String age;
  final String gender;
  final String country;
  final String state;
  final String city;
  final String bio;
  final List<String> interestsId;
  final String deviceToken;
  final String createDate;

  const UserData({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    required this.loginType,
    required this.googleId,
    required this.profilePic,
    required this.coverPic,
    required this.age,
    required this.gender,
    required this.country,
    required this.state,
    required this.city,
    required this.bio,
    required this.interestsId,
    required this.deviceToken,
    required this.createDate,
  });
}
