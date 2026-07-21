import 'package:flutter/material.dart';

class VipLevelHelper {
  static Color getColor(int level) {
    switch (level) {
      case 1:
        return Colors.amber.shade300;
      case 2:
        return Colors.orange.shade300;
      case 3:
        return Colors.deepOrange.shade300;
      case 4:
        return Colors.red.shade300;
      case 5:
        return Colors.purple.shade300;
      case 6:
        return Colors.pink.shade300;
      case 7:
        return Colors.blue.shade300;
      case 8:
        return Colors.cyan.shade300;
      case 9:
        return Colors.teal.shade300;
      case 10:
        return Colors.green.shade300;
      case 11:
        return Colors.lime.shade300;
      case 12:
        return Colors.yellow.shade300;
      case 13:
        return Colors.amber.shade400;
      case 14:
        return Colors.orange.shade400;
      case 15:
        return Colors.deepPurple.shade300;
      default:
        return Colors.grey.shade400;
    }
  }

  static Color getSvipColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFFFC107);
      case 3:
        return const Color(0xFFFFB300);
      case 4:
        return const Color(0xFFFFA000);
      case 5:
        return const Color(0xFFFF8F00);
      default:
        return Colors.amber.shade400;
    }
  }
}