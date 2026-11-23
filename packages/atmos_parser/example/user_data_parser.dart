// Author: `Gilyazeev Adel` (@Atom735)
// Created Date: `2023-10-16`

import 'package:atmos_parser/atmos_parser.dart';

import 'user_data.dart';

class UserDataParser extends AtmosParser<UserData> {
  const UserDataParser();

  @override
  UserData? parse(Object? input) {
    if (input is UserData?) return input;
    return UserData(
      id: v('id') ?? '',
      name: v('fullname') ?? '',
      username: v('username') ?? '',
      email: v('email') ?? '',
      phone: v('phone') ?? '',
      password: v('password') ?? '',
      loginType: v('login_type') ?? '',
      googleId: v('google_id') ?? '',
      profilePic: v('profile_pic') ?? '',
      coverPic: v('cover_pic') ?? '',
      age: v('age') ?? '',
      gender: v('gender') ?? '',
      country: v('country') ?? '',
      state: v('state') ?? '',
      city: v('city') ?? '',
      bio: v('bio') ?? '',
      interestsId: list('interests_id') ?? const [],
      deviceToken: v('device_token') ?? '',
      createDate: v('create_date') ?? '',
    );
  }

  @override
  Object? serialize(UserData? input) {
    if (input == null) return null;
    return {
      'id': s(input.id),
      'fullname': s(input.name),
      'username': s(input.username),
      'email': s(input.email),
      'phone': s(input.phone),
      'password': s(input.password),
      'login_type': s(input.loginType),
      'google_id': s(input.googleId),
      'profile_pic': s(input.profilePic),
      'cover_pic': s(input.coverPic),
      'age': s(input.age),
      'gender': s(input.gender),
      'country': s(input.country),
      'state': s(input.state),
      'city': s(input.city),
      'bio': s(input.bio),
      'linterests_id': sList(input.interestsId),
      'device_token': s(input.deviceToken),
      'create_date': s(input.createDate),
    };
  }
}
