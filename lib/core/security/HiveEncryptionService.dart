import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class HiveEncryptionService {
  static const _secureStorage = FlutterSecureStorage();
  static const _keyName = 'hive_encryption_key';

  static Future<List<int>> getEncryptionKey() async {
    var storedKey = await _secureStorage.read(key: _keyName);

    if (storedKey == null) {
      final key = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _keyName,
        value: base64UrlEncode(key),
      );
      return key;
    }

    return base64Url.decode(storedKey);
  }
}