// ignore_for_file: one_member_abstracts
abstract class AtmosHttpClient {
  Future<void> send(String method, Uri uri);
}
