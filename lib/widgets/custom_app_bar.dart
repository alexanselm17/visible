import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade700, Colors.grey.shade900],
        ),
      ),
      child: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
            ),
            // const Text(
            //   'Manage your active pump sessions sessions',
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 14,
            //     fontWeight: FontWeight.normal,
            //   ),
            // ),
          ],
        ),
        centerTitle: centerTitle,
        actions: actions,
        bottom: bottom,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(bottom?.preferredSize.height ?? kToolbarHeight);
}
