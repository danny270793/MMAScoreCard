import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Debug-only workaround for developing behind a corporate TLS-inspecting
/// proxy (e.g. Zscaler): such proxies re-sign HTTPS traffic with their own
/// root CA, which the OS/browser trust (it's installed system-wide) but
/// Dart's bundled TLS trust store does not, causing every request to fail
/// with `CERTIFICATE_VERIFY_FAILED`.
///
/// This trusts that one specific root CA for the lifetime of the app -
/// never in release/profile builds, so it can't affect real users.
Future<void> trustDevCorporateProxyCertificate() async {
  if (!kDebugMode) return;
  try {
    final pem = await rootBundle.load('assets/dev_certs/zscaler_root_ca.pem');
    SecurityContext.defaultContext.setTrustedCertificatesBytes(
      pem.buffer.asUint8List(),
    );
  } catch (_) {
    // Asset missing or unsupported platform (e.g. web) - ignore, this is
    // only a local-dev convenience.
  }
}
