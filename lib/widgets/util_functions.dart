import 'package:flutter/material.dart';

class UtilFunctions {
  static Future<DateTime?> showDateTimePicker(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    ).then(
      (selectedDate) {
        print(selectedDate);
        if (selectedDate != null) {
          return showTimePicker(
            context: context,
            initialTime: const TimeOfDay(hour: 0, minute: 0),
            initialEntryMode: TimePickerEntryMode.input,
          ).then(
            (selectedTime) {
              print(selectedTime);
              if (selectedTime != null) {
                DateTime returnDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                print(returnDateTime.toString());
                return returnDateTime;
              } else {
                return null;
              }
            },
          );
        } else {
          return null;
        }
      },
    );
  }
}
