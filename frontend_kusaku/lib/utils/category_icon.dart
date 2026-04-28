import 'package:flutter/material.dart';

IconData categoryIcon(String? iconName) {
  switch (iconName?.toLowerCase()) {
    case 'kebutuhan rumah':   return Icons.home;
    case 'makan & minum':     return Icons.restaurant;
    case 'transportasi':      return Icons.directions_car;
    case 'investasi':         return Icons.trending_up;
    case 'tabungan':          return Icons.savings;
    case 'hiburan':           return Icons.sports_esports;
    case 'tagihan':           return Icons.electric_bolt;
    case 'kesehatan':         return Icons.local_hospital;
    case 'pendidikan':        return Icons.school;
    default:                  return Icons.wallet; // fallback for custom category names
  }
}

const List<Map<String, String>> availableCategoryIcons = [
  {'name': 'Kebutuhan Rumah', 'label': 'Kebutuhan Rumah'},
  {'name': 'Makan & Minum',   'label': 'Makan & Minum'},
  {'name': 'Transportasi',    'label': 'Transportasi'},
  {'name': 'Investasi',       'label': 'Investasi'},
  {'name': 'Tabungan',        'label': 'Tabungan'},
  {'name': 'Hiburan',         'label': 'Hiburan'},
  {'name': 'Tagihan',         'label': 'Tagihan'},
  {'name': 'Kesehatan',       'label': 'Kesehatan'},
  {'name': 'Pendidikan',      'label': 'Pendidikan'},
];