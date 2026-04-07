import 'package:flutter/material.dart';

const List<String> kCategoryLabels = [
  'Plant 1',
  'Plant 2',
  'Plant 3',
  'Plant 4',
  'Plant 5',
  'Plant 6',
  'Propagation',
  'Decorations',
];

const List<String> kCategoryKeys = [
  'plant1',
  'plant2',
  'plant3',
  'plant4',
  'plant5',
  'plant6',
  'propagation',
  'decorations',
];

const int kNumCategories = 8;

// Scoresheet row colors (matching the paper scoresheet)
const Color kPlantGreen       = Color(0xFFCFE1C8);
const Color kPropagationYellow = Color(0xFFEAE7B8);
const Color kDecorationsLavender = Color(0xFFCDC0E0);
const Color kTotalPeach       = Color(0xFFF5D5C0);
const Color kHeaderGreen      = Color(0xFF7A9E82);
const Color kHeaderGreenDark  = Color(0xFF5D7E65);
const Color kPlayerHeaderBg   = Color(0xFFF0F0F0);
const Color kPlayerHeaderBgDark = Color(0xFF2A2A2A);

Color rowColorForCategory(int categoryIndex, {bool dark = false}) {
  if (categoryIndex < 6) return dark ? const Color(0xFF2D4030) : kPlantGreen;
  if (categoryIndex == 6) return dark ? const Color(0xFF3D3A20) : kPropagationYellow;
  return dark ? const Color(0xFF2D2840) : kDecorationsLavender;
}
