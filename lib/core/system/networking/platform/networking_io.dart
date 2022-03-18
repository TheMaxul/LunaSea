import 'dart:io';

import '../../../../vendor.dart';
import '../../../database/luna_database.dart';
import '../networking.dart';

bool isPlatformSupported() => true;
LunaNetworking getNetworking() => IO();

class IO extends HttpOverrides implements LunaNetworking {
  @override
  void initialize() {
    HttpOverrides.global = IO();
  }

  String generateUserAgent(PackageInfo info) {
    return '${info.appName}/${info.version} ${info.buildNumber}';
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final HttpClient client = super.createHttpClient(context);

    // Disable TLS validation
    if (!LunaDatabaseValue.NETWORKING_TLS_VALIDATION.data)
      client.badCertificateCallback = (cert, host, port) => true;

    // Set User-Agent
    PackageInfo.fromPlatform()
        .then((info) => client.userAgent = generateUserAgent(info))
        .catchError((_) => client.userAgent = 'LunaSea/Unknown');

    return client;
  }
}
