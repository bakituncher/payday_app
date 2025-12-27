import 'package:flutter/material.dart';

class FeatureIntroPage {
  final IconData icon;
  final String title;
  final String description;
  final List<String> bullets;

  const FeatureIntroPage({
    required this.icon,
    required this.title,
    required this.description,
    this.bullets = const [],
  });
}

