import 'package:flutter/material.dart';

import 'models.dart';

/// The catalog served by the mock backend.
const List<Product> mockProducts = [
  Product(
    id: 'headphones',
    name: 'Studio Headphones',
    description: 'Closed-back, 40 hour battery',
    priceCents: 12900,
    icon: Icons.headphones,
    color: Color(0xFF3F51B5),
  ),
  Product(
    id: 'keyboard',
    name: 'Mechanical Keyboard',
    description: 'Hot-swappable tactile switches',
    priceCents: 8950,
    icon: Icons.keyboard,
    color: Color(0xFF00796B),
  ),
  Product(
    id: 'camera',
    name: 'Pocket Camera',
    description: '4K video with stabilization',
    priceCents: 34900,
    icon: Icons.photo_camera,
    color: Color(0xFFC2185B),
  ),
  Product(
    id: 'watch',
    name: 'Fitness Watch',
    description: 'GPS, heart rate and sleep tracking',
    priceCents: 19900,
    icon: Icons.watch,
    color: Color(0xFFE65100),
  ),
  Product(
    id: 'speaker',
    name: 'Travel Speaker',
    description: 'Waterproof, fits in a jacket pocket',
    priceCents: 5900,
    icon: Icons.speaker,
    color: Color(0xFF5D4037),
  ),
  Product(
    id: 'backpack',
    name: 'Commuter Backpack',
    description: 'Padded laptop sleeve, 22 liters',
    priceCents: 7400,
    icon: Icons.backpack,
    color: Color(0xFF455A64),
  ),
  Product(
    id: 'lamp',
    name: 'Desk Lamp',
    description: 'Dimmable with adjustable warmth',
    priceCents: 4500,
    icon: Icons.light,
    color: Color(0xFF827717),
  ),
  Product(
    id: 'mug',
    name: 'Heated Mug',
    description: 'Keeps coffee at your chosen temperature',
    priceCents: 3200,
    icon: Icons.coffee,
    color: Color(0xFF6A1B9A),
  ),
];
