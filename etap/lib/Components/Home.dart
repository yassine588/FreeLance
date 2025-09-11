import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/commodity.dart';

class EtapPage extends StatefulWidget {
  final String apiBaseUrl = 'http://192.168.1.12:3000';

  const EtapPage({Key? key}) : super(key: key);

  @override
  State<EtapPage> createState() => _EtapPageState();
}

class _EtapPageState extends State<EtapPage> {
  CommodityType _selectedCommodity = CommodityType.brent;
  Map<CommodityType, CommodityData> _commodityData = {};
  Timer? _timer;
  bool _isLoading = true;
  String _errorMessage = '';
  Duration _selectedPeriod = Duration(minutes: 10); // Default period for chart history
  Duration _selectedRefresh = Duration(seconds: 30); // Default refresh interval

  // Define available periods for user selection (now includes 1 second)
  final List<Duration> _availablePeriods = [
    Duration(seconds: 1),
    Duration(seconds: 40),
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(hours: 1),
    Duration(hours: 6),
    Duration(days: 1),
    Duration(days: 7),
    Duration(days: 30),
    Duration(days: 365),
  ];

  // Define available refresh intervals for user selection (now includes 1 second)
  final List<Duration> _refreshIntervals = [
    Duration(seconds: 1),
    Duration(seconds: 10),
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 10),
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(_selectedRefresh, (_) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Whenever the refresh interval changes, cancel and restart the timer
  void _updateRefreshInterval(Duration newInterval) {
    setState(() {
      _selectedRefresh = newInterval;
      _timer?.cancel();
      _timer = Timer.periodic(_selectedRefresh, (_) => _fetchData());
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await http
          .get(Uri.parse("${widget.apiBaseUrl}/prices"))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Fetched data: $data');
        setState(() {
          _commodityData = {
            CommodityType.brent: _buildCommodityData(
              "Brent Crude Oil",
              (data["brent"]["price"] ?? 0.0) * 1.0,
              "barrel",
              Colors.blue,
              data["brent"]["currency"] ?? "USD",
              _extractHistoricalPrices(data["brent"]["historical"]),
            ),
            CommodityType.naturalGas: _buildCommodityData(
              "Natural Gas",
              (data["naturalGas"]["price"] ?? 0.0) * 1.0,
              "MMBtu",
              Colors.green,
              data["naturalGas"]["currency"] ?? "USD",
              _extractHistoricalPrices(data["naturalGas"]["historical"]),
            ),
            CommodityType.gasoline: _buildCommodityData(
              "Gasoline",
              (data["gasoline"]["price"] ?? 0.0) * 1.0,
              "gallon",
              Colors.orange,
              data["gasoline"]["currency"] ?? "USD",
              _extractHistoricalPrices(data["gasoline"]["historical"]),
            ),
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load data: Server returned ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
        _isLoading = false;
      });
      debugPrint("Error fetching data: $e");
    }
  }

  // Extracts prices from historical data objects, expects each item to have {price:..., timestamp:...}
  List<Map<String, dynamic>> _extractHistoricalPrices(List<dynamic>? historicalData) {
    if (historicalData == null) return [];
    return historicalData.map<Map<String, dynamic>>((item) {
      if (item is Map<String, dynamic>) {
        return {
          'price': (item['price'] ?? 0.0).toDouble(),
          'timestamp': DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now(),
        };
      } else if (item is num) {
        return {
          'price': item.toDouble(),
          'timestamp': DateTime.now(),
        };
      } else {
        return {
          'price': 0.0,
          'timestamp': DateTime.now(),
        };
      }
    }).toList();
  }

  // Filters historical data to match the selected period
  List<double> _filterHistoricalForPeriod(List<Map<String, dynamic>> historicalData, DateTime now) {
    // Only keep data points within the selected period from now
    return historicalData
        .where((item) => now.difference(item['timestamp'] as DateTime) <= _selectedPeriod)
        .map<double>((item) => item['price'] as double)
        .toList();
  }

  CommodityData _buildCommodityData(
    String name,
    double price,
    String unit,
    Color color,
    String currency,
    List<Map<String, dynamic>> historicalRaw,
  ) {
    final now = DateTime.now();
    final historicalData = _filterHistoricalForPeriod(historicalRaw, now);
    double prevPrice = (historicalData.length > 1)
        ? historicalData[historicalData.length - 2]
        : price;
    double change = price - prevPrice;
    double changePercent = (prevPrice != 0) ? (change / prevPrice) * 100 : 0.0;

    return CommodityData(
      name: name,
      price: price,
      change: change,
      changePercent: changePercent,
      unit: unit,
      color: color,
      historicalData: historicalData,
      lastUpdated: now,
      currency: currency,
    );
  }

  String _periodLabel(Duration period) {
    if (period.inSeconds < 60) return '${period.inSeconds} seconds';
    if (period.inMinutes < 60) return '${period.inMinutes} minutes';
    if (period.inHours < 24) return '${period.inHours} hours';
    if (period.inDays < 7) return '${period.inDays} days';
    if (period.inDays < 30) return '${(period.inDays / 7).round()} weeks';
    if (period.inDays < 365) return '${(period.inDays / 30).round()} months';
    return '${(period.inDays / 365).round()} years';
  }

  String _refreshLabel(Duration period) {
    if (period.inSeconds < 60) return '${period.inSeconds} seconds';
    if (period.inMinutes < 60) return '${period.inMinutes} minutes';
    if (period.inHours < 24) return '${period.inHours} hours';
    return '${period.inDays} days';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading commodity data...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final commodity = _commodityData[_selectedCommodity];
    if (commodity == null) {
      return const Scaffold(
        body: Center(
          child: Text('No data available for selected commodity'),
        ),
      );
    }

    final priceFormat = NumberFormat.currency(symbol: _getCurrencySymbol(commodity.currency), decimalDigits: 2);
    final timeFormat = DateFormat('HH:mm:ss');
    final chartLabel = "Price History (Last ${_periodLabel(_selectedPeriod)})";

    return Scaffold(
      appBar: AppBar(
        title: const Text("ETAP • Dashboard"),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Period selector for chart history
            Row(
              children: [
                const Text(
                  "Select time period: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                DropdownButton<Duration>(
                  value: _selectedPeriod,
                  items: _availablePeriods.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(_periodLabel(period)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPeriod = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  "Auto refresh every: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                DropdownButton<Duration>(
                  value: _selectedRefresh,
                  items: _refreshIntervals.map((interval) {
                    return DropdownMenuItem(
                      value: interval,
                      child: Text(_refreshLabel(interval)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _updateRefreshInterval(val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Commodity selector
            DropdownButtonFormField<CommodityType>(
              value: _selectedCommodity,
              decoration: const InputDecoration(
                labelText: 'Select Commodity',
                border: OutlineInputBorder(),
              ),
              items: CommodityType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    _getCommodityDisplayName(type),
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCommodity = val);
              },
            ),
            const SizedBox(height: 20),

            // Price Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      commodity.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Updated: ${timeFormat.format(commodity.lastUpdated)}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      priceFormat.format(commodity.price),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${commodity.change >= 0 ? "+" : ""}${priceFormat.format(commodity.change)} (${commodity.changePercent.toStringAsFixed(2)}%)",
                      style: TextStyle(
                        fontSize: 16,
                        color: commodity.change >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Per ${commodity.unit}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Chart Title
            Text(
              chartLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Chart
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: commodity.historicalData.length > 1
                          ? (commodity.historicalData.length - 1).toDouble()
                          : 1,
                      minY: commodity.historicalData.isNotEmpty
                          ? commodity.historicalData.reduce((a, b) => a < b ? a : b) * 0.99
                          : 0,
                      maxY: commodity.historicalData.isNotEmpty
                          ? commodity.historicalData.reduce((a, b) => a > b ? a : b) * 1.01
                          : 1,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: const Color(0xff37434d), width: 1),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: commodity.historicalData.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value);
                          }).toList(),
                          isCurved: true,
                          color: commodity.color,
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            color: commodity.color.withOpacity(0.1),
                          ),
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCommodityDisplayName(CommodityType type) {
    switch (type) {
      case CommodityType.brent:
        return "Brent Crude Oil";
      case CommodityType.naturalGas:
        return "Natural Gas";
      case CommodityType.gasoline:
        return "Gasoline";
      default:
        return type.toString().split('.').last;
    }
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return '\$';
    }
  }
}