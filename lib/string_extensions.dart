import 'package:flutter/widgets.dart';

extension StringExtensions on String {
  String localize(BuildContext context) {
    return this; //todo //AppLocalizations.of(context).localize(this);
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
