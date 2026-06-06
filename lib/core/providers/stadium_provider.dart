import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/stadium_model.dart';
import '../services/api_service.dart';

class StadiumProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<StadiumModel> _allStadiums = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<StadiumModel> get allStadiums => _allStadiums;

  Future<void> fetchStadiums() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.get('/playgrounds');
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> data = response.data['data'];
        _allStadiums = data.map((json) => StadiumModel.fromJson(json)).toList();
      } else {
        debugPrint('Fetch Stadiums API failed or status code != 200: ${response.statusCode}, data: ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('Fetch Stadiums Dio Error: ${e.message}, response: ${e.response?.data}');
    } catch (e, stack) {
      debugPrint('Fetch Stadiums Unexpected Error: $e\n$stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<StadiumModel> searchStadiums(String query, {String sport = 'All'}) {
    return _allStadiums.where((stadium) {
      final bool matchesSport = sport == 'All' || stadium.sport == sport;
      final bool matchesSearch = stadium.name.toLowerCase().contains(query.toLowerCase()) || 
                                 stadium.location.toLowerCase().contains(query.toLowerCase());
      return matchesSport && matchesSearch;
    }).toList();
  }
}
