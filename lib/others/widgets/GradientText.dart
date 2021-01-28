import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  GradientText(this.content,
      {@required this.gradient, this.style, this.textAlign = TextAlign.left});

  final String content;
  final Gradient gradient;
  final TextStyle style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(Offset.zero & bounds.size);
      },
      child: Text(
        content,
        textAlign: textAlign,
        style: (style == null)
            ? TextStyle(color: Colors.white)
            : style.copyWith(color: Colors.white),
      ),
    );
  }
}
