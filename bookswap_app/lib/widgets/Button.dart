import 'package:flutter/material.dart';
import '../constants/colors.dart';

enum ButtonType { signIn, post, cancel }

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.signIn,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case ButtonType.signIn:
        backgroundColor = AppColors.yellow;
        textColor = Colors.white;
        break;
      case ButtonType.post:
        backgroundColor = AppColors.yellow;
        textColor = Colors.white;
        break;
      case ButtonType.cancel:
        backgroundColor = Colors.yellow;
        textColor = Colors.black;
        break;
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: textColor, fontSize: 16)),
    );
  }
}
