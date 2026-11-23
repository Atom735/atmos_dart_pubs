// Author: `Gilyazeev Adel` (@Atom735)
// Created Date: `2023-10-16`

import 'package:atmos_parser/atmos_parser.dart';

import 'user_data_parser.dart';
import 'user_ext_data.dart';

class UserExtDataParser extends AtmosParser<UserExtData> {
  const UserExtDataParser();
  @override
  UserExtData? parse(Object? input) {
    if (input is UserExtData?) return input;
    return UserExtData(
      responseCode: v('response_code') ?? '',
      message: v('message') ?? '',
      user: v('user', const UserDataParser()),
      userPost: v('user_post') ?? '',
      followers: v('followers') ?? '',
      following: v('following') ?? '',
      status: v('status') ?? '',
    );
  }

  @override
  Object? serialize(UserExtData? input) {
    if (input == null) return null;
    throw UnimplementedError();
  }
}
