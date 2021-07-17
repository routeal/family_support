import 'package:flutter/material.dart';

const List<Map<String, String>> FavoriteColors = [
  {'name': 'vivid red', 'value': '#d62264'},
  {'name': 'vivid purple', 'value': '#5b2af4'},
  {'name': 'vivid cyan', 'value': '#07dbc1'},
  {'name': 'vivid yellow', 'value': '#f7e21e'},
  {'name': 'vivid orange', 'value': '#ff8017'},
  {'name': 'vivid green', 'value': '#b4f22f'},
  {'name': 'vivid blue', 'value': '#0080ff'},
  {'name': 'vivid pink', 'value': '#ff5a8d'},
  {'name': 'pastel red', 'value': '#ffc5dd'},
  {'name': 'pastel purple', 'value': '#a694ff'},
  {'name': 'pastel cyan', 'value': '#92efdf'},
  {'name': 'pastel yellow', 'value': '#fff099'},
  {'name': 'pastel orange', 'value': '#e2ab86'},
  {'name': 'pastel green', 'value': '#dcf492'},
  {'name': 'pastel blue', 'value': '#9bcff9'},
  {'name': 'pastel pink', 'value': '#f97591'},
  {'name': 'earth red', 'value': '#ad6180'},
  {'name': 'earth purple', 'value': '#5a518e'},
  {'name': 'earth cyan', 'value': '#59998e'},
  {'name': 'earth yellow', 'value': '#d6cb8a'},
  {'name': 'earth orange', 'value': '#9e8a7b'},
  {'name': 'earth green', 'value': '#a7b77b'},
  {'name': 'earth blue', 'value': '#6c97ba'},
  {'name': 'earth pink', 'value': '#c66f6f'},
];

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
