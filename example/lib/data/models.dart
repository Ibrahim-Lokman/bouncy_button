import 'package:flutter/material.dart';

/// An item in the mock catalog.
@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String description;
  final int priceCents;
  final IconData icon;
  final Color color;
}

/// Formats a price held in cents, avoiding floating-point money.
String formatPrice(int cents) {
  final dollars = cents ~/ 100;
  final remainder = (cents % 100).toString().padLeft(2, '0');
  return '\$$dollars.$remainder';
}
