
import 'package:edit_calendar_event_view/string_extensions.dart';
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
    if (MacosTheme.of(context) != null) {
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
                                                child: Text(button.$1!),
                                                onPressed: () {
                                                    Navigator.of(context).pop();
                                                    if (button.$2 != null) {
                                                      button.$2!();
                                                    }
                                                },
                                    secondary:
                                                    buttons.indexOf(button) !=
                                                        buttons.length - 1,
                                              ))
                                          .toList(),
                                ),
                              )
                          ],
                        ),
                      ));
                }),
              ));
    } else {
      final alertDialog = AlertDialog(
          titlePadding: EdgeInsets.all(16.0),
          title: title == null
              ? null
              : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              if (subTitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(subTitle,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
            ],
          ),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          insetPadding: insetPadding ??
              EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          contentPadding: EdgeInsets.zero,
          content:
          Container(height: maxHeight, width: maxWidth, child: body),
          actions: buttons
              ?.map((button) => TextButton(
              child: Text(button.$1!),
              onPressed: () {
                  Navigator.of(context).pop();
                  if (button.$2 != null) {
                    button.$2!();
                }
              }))
              .toList());
      if( animateFrom == null) {
        return showDialog(
            context: context,
            barrierDismissible: barrierDismissible,
            barrierColor: barrierColor ?? Colors.black54,
            builder: (BuildContext context) {
              return alertDialog;
            });
      } else {
        return showGeneralDialog(
            context: context,
            barrierDismissible: barrierDismissible,
            barrierColor: barrierColor ?? Colors.black54,
            transitionDuration: const Duration(milliseconds: 150),
            barrierLabel: 'close'.localize(context),
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              final begin = animateFrom;
              const end = Offset.zero;
              var offset = Tween(begin: begin, end: end).animate(animation);
              var size = Tween(begin: 0.4, end: 1.0).animate(animation);
              final fade = Tween(begin: 0.2, end: 1.0).animate(animation);
              return SlideTransition(
                position: offset,
                child: ScaleTransition(
                    scale: size,
                    child: FadeTransition(
                      opacity: fade,
                      child: alertDialog,
                    )),
              );
            },
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return alertDialog;
            });
      }
    }
  }
}
