import 'package:flutter/material.dart';

class NavigationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const NavigationItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyMedium?.color;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 24,
      ),
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: color,
        ),
      ),
      onTap: () {
        onTap();
        Navigator.of(context).pop(); // close the drawer
      },
    );
  }
}
