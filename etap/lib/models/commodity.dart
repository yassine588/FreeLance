import 'package:flutter/material.dart';

enum CommodityType { brent, naturalGas, gasoline }

class CommodityData {
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final String unit;
  final Color color;
  final List<double> historicalData;
  final DateTime lastUpdated;
  final String currency; // <-- add this line

  CommodityData({
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.unit,
    required this.color,
    required this.historicalData,
    required this.lastUpdated,
    required this.currency, // <-- add this line
  });

  factory CommodityData.fromJson(Map<String, dynamic> json, CommodityType type) {
    Color color;
    switch (type) {
      case CommodityType.naturalGas:
        color = Colors.green;
        break;
      case CommodityType.gasoline:
        color = Colors.orange;
        break;
      case CommodityType.brent:
      default:
        color = Colors.blue;
    }

    return CommodityData(
      name: json['name'] ?? type.toString().split('.').last,
      price: (json['price'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'barrel',
      color: color,
      historicalData: List<double>.from(json['historicalData'] ?? []),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      currency: json['currency'] ?? 'USD', // <-- add this line
    );
  }

  CommodityData copyWith({
    String? name,
    double? price,
    double? change,
    double? changePercent,
    String? unit,
    Color? color,
    List<double>? historicalData,
    DateTime? lastUpdated,
    String? currency, // <-- add this line
  }) {
    return CommodityData(
      name: name ?? this.name,
      price: price ?? this.price,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      unit: unit ?? this.unit,
      color: color ?? this.color,
      historicalData: historicalData ?? this.historicalData,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currency: currency ?? this.currency, 
    );
  }
}