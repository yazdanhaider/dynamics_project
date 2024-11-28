import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;
  SortOption _currentSort = SortOption.none;

  List<Product> get products => _filterProducts();
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  SortOption get currentSort => _currentSort;

  // Get unique categories
  List<String> get categories {
    final Set<String> uniqueCategories =
        _products.map((p) => p.category.name).toSet();
    return uniqueCategories.toList()..sort();
  }

  List<Product> _filterProducts() {
    List<Product> filteredProducts = _products;

    // Apply category filter
    if (_selectedCategory != null) {
      filteredProducts = filteredProducts
          .where((product) => product.category.name == _selectedCategory)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((product) =>
              product.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply sorting
    switch (_currentSort) {
      case SortOption.priceHighToLow:
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.priceLowToHigh:
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.newest:
        filteredProducts.sort((a, b) => b.creationAt.compareTo(a.creationAt));
        break;
      case SortOption.oldest:
        filteredProducts.sort((a, b) => a.creationAt.compareTo(b.creationAt));
        break;
      case SortOption.none:
        break;
    }

    return filteredProducts;
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategory(String? categoryName) {
    if (_selectedCategory == categoryName) {
      _selectedCategory = null; // Deselect if already selected
    } else {
      _selectedCategory = categoryName;
    }
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _currentSort = option;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://api.escuelajs.co/api/v1/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _products = data.map((json) => Product.fromJson(json)).toList();
        _error = null;
      } else {
        _error = 'Failed to load products';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

enum SortOption {
  none,
  priceHighToLow,
  priceLowToHigh,
  newest,
  oldest,
}

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.none:
        return 'Default';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.newest:
        return 'Newest First';
      case SortOption.oldest:
        return 'Oldest First';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.none:
        return Icons.sort;
      case SortOption.priceHighToLow:
        return Icons.arrow_downward;
      case SortOption.priceLowToHigh:
        return Icons.arrow_upward;
      case SortOption.newest:
        return Icons.update;
      case SortOption.oldest:
        return Icons.history;
    }
  }
}
