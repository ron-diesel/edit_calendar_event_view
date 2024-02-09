import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';


extension ListExtensions<T> on List<T> {
  T? firstOrNull() {
    try {
      return first;
    } catch (e) {
      return null;
    }
  }

  T? atIndexOrNull(int index) {
    try {
      return this[index];
    } catch (e) {
      return null;
    }
  }

  List<List<T>> splitWhere(bool Function(T element) predicate) {
    List<List<T>> result = [];
    List<T> currentList = [];
    for (T element in this) {
      if (predicate(element)) {
        result.add(currentList);
        currentList = [];
      } else {
        currentList.add(element);
      }
    }
    result.add(currentList);
    return result;
  }
}

extension DateTimeExtension on DateTime {
  bool isBeforeOrSame(DateTime date) {
    return !isAfter(date);
  }

  bool isAfterOrSame(DateTime date) {
    return !isBefore(date);
  }

  bool isBeforeOrSameDay(DateTime date) {
    return year < date.year ||
        year == date.year &&
            (month < date.month || month == date.month && day <= date.day);
  }

  bool isSameDay(DateTime date) {
    return year == date.year && month == date.month && day == date.day;
  }

  bool isAfterOrSameDay(DateTime date) {
    return year > date.year ||
        year == date.year &&
            (month > date.month || month == date.month && day >= date.day);
  }

  bool isBeforeDay(DateTime date) {
    return year < date.year ||
        year == date.year &&
            (month < date.month || month == date.month && day < date.day);
  }

  DateTime beginningOfDay() {
    return DateTime(year, month, day);
  }

  DateTime endOfDay() {
    return DateTime(
        year,
        month,
        day,
        23,
        59,
        59,
        999);
  }

  DateTime beginningOfMonth() {
    return DateTime(year, month, 1);
  }
}