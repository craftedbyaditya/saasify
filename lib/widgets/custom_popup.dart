import 'package:flutter/material.dart';

class CustomOverlayDialog extends StatelessWidget {
  final String title;
  final String content;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;

  const CustomOverlayDialog({
    super.key,
    required this.title,
    required this.content,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white, // White background for the overlay
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 10.0, // Enhanced shadow for overlay effect
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(content, style: const TextStyle(fontSize: 14.0)),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (secondaryButtonText != null && onSecondaryPressed != null)
                  TextButton(
                    onPressed: onSecondaryPressed,
                    child: Text(secondaryButtonText!),
                  ),
                ElevatedButton(
                  onPressed: onPrimaryPressed,
                  child: Text(primaryButtonText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
