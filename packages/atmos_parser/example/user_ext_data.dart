// Author: `Gilyazeev Adel` (@Atom735)
// Created Date: `2023-10-16`

import 'package:meta/meta.dart';

import 'user_data.dart';

@immutable
class UserExtData {
  final String responseCode;
  final String message;
  final UserData? user;
  final String userPost;
  final String followers;
  final String following;
  final String status;

  const UserExtData({
    required this.responseCode,
    required this.message,
    required this.user,
    required this.userPost,
    required this.followers,
    required this.following,
    required this.status,
  });
}
