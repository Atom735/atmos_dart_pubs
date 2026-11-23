// Author: `Gilyazeev Adel` (@Atom735)
// Created Date: `2023-10-18`

import 'dart:developer';

import 'package:atmos_parser/atmos_parser.dart';

import 'user_data.dart';
import 'user_data_parser.dart';
import 'user_response_data.dart';

class UserResponseDataParser extends AtmosParser<UserResponseData> {
  const UserResponseDataParser();

  @override
  AtmosParsers get deps => const AtmosParsers({
        UserData: UserDataParser(),
      });

  @override
  UserResponseData? parse(Object? input) {
    if (input is UserResponseData?) return input;
    try {
      return UserResponseData(
        responseCode: v('response_code') ?? -1,
        message: v('message') ?? '',
        status: v('status') ?? '',
        user: v('user'),
        userToken: v('user_token') ?? '',
      );
    } finally {
      final unusedKeys = AtmosParserContext.get.keysUnused;
      if (unusedKeys.isNotEmpty) {
        debugger();
        print('unused keys: ${unusedKeys.join(', ')}\nFrom data\n$input');
      }
    }
  }

  @override
  Object? serialize(UserResponseData? input) {
    if (input == null) return null;
    return {
      'response_code': s(input.responseCode),
      'message': s(input.message),
      'status': s(input.status),
      'user': s(input.user),
      'user_token': s(input.userToken),
    };
  }
}
