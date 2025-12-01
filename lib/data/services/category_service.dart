import 'package:dio/dio.dart';
import 'package:flutter_restaurante/config/environment.dart';
import 'package:flutter_restaurante/data/models/category.dart';

class CategoryService {
  final Dio _dio = Dio(BaseOptions(baseUrl: Environment.apiUrl));

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories/');
      final data = response.data as List;
      return data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
