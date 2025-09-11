import 'package:flutter/foundation.dart';
import '../models/commodity.dart';
import '../services/commodity_service.dart';

class CommodityProvider with ChangeNotifier {
  final CommodityService _commodityService;
  CommodityType _selectedCommodity = CommodityType.brent;
  Map<CommodityType, CommodityData> _commodityData = {};
  bool _isLoading = false;
  String _error = '';

  CommodityProvider(this._commodityService);

  CommodityType get selectedCommodity => _selectedCommodity;
  CommodityData? get currentCommodity => _commodityData[_selectedCommodity];
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadCommodityData() async {
    _setLoading(true);
    _error = '';

    try {
      // Load all commodities data
      final data = await _commodityService.fetchAllCommodities();
      debugPrint('Fetched commodity data=====: $data');
      for (var type in CommodityType.values) {
        final typeStr = _commodityTypeToString(type);
        if (data.containsKey(typeStr)) {
          _commodityData[type] = CommodityData.fromJson(data[typeStr], type);
        }
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      // Fallback to mock data if API fails
      _setMockData();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshCommodityData() async {
    await loadCommodityData();
  }

  void selectCommodity(CommodityType type) {
    _selectedCommodity = type;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String _commodityTypeToString(CommodityType type) {
    return type.toString().split('.').last;
  }

  void _setMockData() {
    // Fallback mock data in case API fails
    _commodityData = {
      CommodityType.brent: CommodityData(
        name: "Brent Crude Oil",
        price: 84.50,
        change: 0.45,
        changePercent: 0.54,
        unit: "barrel",
        color: Colors.blue,
        historicalData: [83.2, 83.5, 83.8, 84.1, 84.3, 84.6, 84.5, 84.7, 84.4, 84.5],
        lastUpdated: DateTime.now(),
      ),
      CommodityType.naturalGas: CommodityData(
        name: "Natural Gas",
        price: 2.85,
        change: -0.12,
        changePercent: -4.04,
        unit: "MMBtu",
        color: Colors.green,
        historicalData: [2.98, 2.95, 2.92, 2.89, 2.87, 2.86, 2.85, 2.86, 2.85, 2.85],
        lastUpdated: DateTime.now(),
      ),
      CommodityType.gasoline: CommodityData(
        name: "Gasoline",
        price: 3.42,
        change: 0.08,
        changePercent: 2.39,
        unit: "gallon",
        color: Colors.orange,
        historicalData: [3.32, 3.35, 3.37, 3.39, 3.40, 3.41, 3.42, 3.43, 3.42, 3.42],
        lastUpdated: DateTime.now(),
      ),
    };
  }
}