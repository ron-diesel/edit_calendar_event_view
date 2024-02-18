
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';


class MultiPlatformDialog {
  static const radius = 8.0;

  static Future<dynamic> show(BuildContext context, Widget body,
      {String? title,
      String? subTitle,
      List<(String?, VoidCallback?)>? buttons,
      bool barrierDismissible = true,
      Color? barrierColor,
      double? maxWidth,
      double? maxHeight,
      Color? backgroundColor,
      EdgeInsets? insetPadding, Offset? animateFrom}) {
    return showMacosAlertDialog(
        context: context,
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        builder: (context) => Theme(
              data: ThemeData(brightness: MacosTheme.of(context).brightness),
              child: Builder(builder: (context) {
                return Dialog(
                    backgroundColor: backgroundColor ??
                        Theme.of(context).dialogTheme.backgroundColor,
                    insetPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radius)),
                    child: Container(
                      constraints: maxWidth == null && maxHeight == null
                          ? null
                          : BoxConstraints(
                              maxHeight: maxHeight!, maxWidth: maxWidth!),
                      child: Column(
                        children: [
                          if (title != null)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                title,
                                style: MacosTheme.of(context)
                                    .typography
                                    .largeTitle
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          if (subTitle != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(subTitle,
                                  style: MacosTheme.of(context)
                                      .typography
                                      .title1),
                            ),
                          Expanded(child: body),
                          if (buttons?.isNotEmpty ?? false)
                            Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.all(16.0),
                              child: Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 4.0,
                                children: buttons == null
                                    ? []
                                    : buttons
                                        .map((button) => PushButton(
                                  controlSize: ControlSize.large,
                                              onPressed: () {
                                                  Navigator.of(context).pop();
                                                  if (button.$2 != null) {
                                                    button.$2!();
                                                  }
                                              },
                                  secondary:
                                                  buttons.indexOf(button) !=
                                                      buttons.length - 1,
                                              child: Text(button.$1!),
                                            ))
                                        .toList(),
                              ),
                            )
                        ],
                      ),
                    ));
              }),
            ));
    }
}
