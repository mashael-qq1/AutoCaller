import 'dart:convert';
import 'package:cryptography/cryptography.dart';

class Signer {
  final String privateKey;

  Signer(this.privateKey);

  Future<List<int>> sign(String input) async {
    final algorithm = RsaSsaPkcs1v15(
      hashAlgorithm: Sha256(),
    );

    // Convert the private key PEM string into bytes
    final privateKeyBytes = base64.decode(
      privateKey
          .replaceAll('-----BEGIN PRIVATE KEY-----\n', '')
          .replaceAll('\n-----END PRIVATE KEY-----\n', '')
          .replaceAll('\n', ''),
    );

    // Load the private key
    final keyPair = RsaKeyPairData(
      privateKey: privateKeyBytes,
    );

    // Sign the input
    final signature = await algorithm.sign(
      utf8.encode(input),
      keyPair: keyPair,
    );

    return signature.bytes;
  }
}