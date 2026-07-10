import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final Box<Category> _categoryBox = Hive.box<Category>('categories');

  List<Category> get categories => _categoryBox.values.toList();

  Future<void> addCategory(Category category) async {
    await _categoryBox.put(category.id, category);
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    await category.save();
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await _categoryBox.delete(id);
    notifyListeners();
  }

  Category? getCategoryById(String id) {
    return _categoryBox.get(id);
  }

  Future<void> clearAll() async {
    await _categoryBox.clear();
    notifyListeners();
  }
}
