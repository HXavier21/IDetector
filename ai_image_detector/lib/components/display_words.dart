import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DisplayWords extends StatelessWidget {
  const DisplayWords({super.key, this.onClick});
  final Function? onClick;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            text: 'Just ',
            style: TextStyle(color: Colors.black, fontSize: 32),
            children: [
              TextSpan(
                text: 'drop',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextSpan(
                text: ' your image',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            text: "or ",
            style: TextStyle(color: Colors.black, fontSize: 16),
            children: [
              TextSpan(
                text: "click here ",
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    onClick?.call();
                  },
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              TextSpan(
                text: "to upload.",
              )
            ],
          ),
        )
      ],
    );
  }
}
