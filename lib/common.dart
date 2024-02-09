
import 'dart:io';

bool isUnifiedMacOsStyle() {
  if (Platform.isMacOS == false) {
    return false;
  }
  // keep all digit and . characters using a regular expression
  final versionNumberStr = Platform.operatingSystemVersion.replaceAll(RegExp(r'[^0-9\.]'), '');

  var majorVersion = int.tryParse(versionNumberStr.split('.')[0]);

  // Return true if the major version is Ventura (13.0) or higher, blank screen if unified configured for older versions than that
  return majorVersion != null && majorVersion >= 13;
}