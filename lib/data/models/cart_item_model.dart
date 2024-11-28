import 'product_model.dart';

class CartItem {
  final int id;
  final int productId;
  final String title;
  final double price;
  final String image;
  final String category;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.category,
    this.quantity = 1,
  });

  double get total => price * quantity;

  CartItem copyWith({
    int? id,
    int? productId,
    String? title,
    double? price,
    String? image,
    String? category,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromProduct(Product product) {
    return CartItem(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: product.id,
      title: product.title,
      price: product.price,
      image: product.images.isNotEmpty
          ? product.images.first
          : product.category.image,
      category: product.category.name,
    );
  }
}
