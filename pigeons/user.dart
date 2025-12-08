import 'package:pigeon/pigeon.dart';

class PigeonUser {
  final String? uid;
  final String? email;
  final String? displayName;

  PigeonUser({
    this.uid,
    this.email,
    this.displayName,
  });
}

@HostApi()
abstract class UserApi {
  PigeonUser? getUser();
  void saveUser(PigeonUser user);
}
