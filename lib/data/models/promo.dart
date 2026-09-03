import 'package:flutter/material.dart';

class Promo {
  const Promo({
    required this.id,
    required this.badge,
    required this.title,
    required this.description,
    required this.gradient,
    required this.body,
    required this.icon,
  });

  final String id;
  final String badge;
  final String title;
  final String description;
  final List<Color> gradient;
  final List<String> body;
  final IconData icon;
}
