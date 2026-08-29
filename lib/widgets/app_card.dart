import 'package:flutter/material.dart';

import '../theme.dart';

/// Mirrors the `.card` block in styles.css:
/// white background, 15px radius, 1px #e9ecef border, soft shadow.
class AppCard extends StatelessWidget {
  final Widget? title;
  final String? heading;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    this.title,
    this.heading,
    required this.child,
    this.padding = const EdgeInsets.all(32),
    this.margin,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 24),
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColorsExtension.of(context).bgPrimary,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColorsExtension.of(context).bgTertiary),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            DefaultTextStyle(
              style: Theme.of(context).textTheme.titleLarge!,
              child: title!,
            ),
            const SizedBox(height: 8),
          ] else if (heading != null) ...[
            Text(
              heading!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
          ],
          child,
        ],
      ),
    );
  }
}
