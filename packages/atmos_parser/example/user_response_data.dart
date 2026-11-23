// Author: `Gilyazeev Adel` (@Atom735)
// Created Date: `2023-10-18`

import 'package:meta/meta.dart';

import 'user_data.dart';

@immutable
class UserResponseData {
  final int responseCode;
  final String message;
  final String status;
  final UserData? user;
  final String userToken;

  const UserResponseData({
    required this.responseCode,
    required this.message,
    required this.status,
    required this.user,
    required this.userToken,
  });
}
