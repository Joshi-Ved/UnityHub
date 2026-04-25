import 'package:flutter/material.dart';

class UnityHubButton extends StatelessWidget {
  const UnityHubButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.mobile = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(mobile ? double.infinity : 160, mobile ? 52 : 44),
      ),
    );

    if (icon == null) {
      return SizedBox(
        width: mobile ? double.infinity : null,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(mobile ? double.infinity : 160, mobile ? 52 : 44),
          ),
          child: Text(label),
        ),
      );
    }

    return SizedBox(width: mobile ? double.infinity : null, child: button);
  }
}
