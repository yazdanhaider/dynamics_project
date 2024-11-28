class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final List<String> images;
  final DateTime creationAt;
  final DateTime updatedAt;
  final Category category;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.images,
    required this.creationAt,
    required this.updatedAt,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Clean and validate image URLs
    List<String> cleanImages = [];
    final rawImages = json['images'] as List;

    for (var img in rawImages) {
      String cleanUrl = img
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .replaceAll('\\', '');

      // Add "https://" if it's just an Imgur ID
      if (cleanUrl.startsWith('imgur.com/')) {
        cleanUrl = 'https://' + cleanUrl;
      }

      // Handle pravatar.cc URLs
      if (cleanUrl.contains('pravatar.cc') &&
          !cleanUrl.contains('i.pravatar.cc')) {
        cleanUrl = 'https://i.pravatar.cc/300?u=${json['id']}';
      }

      cleanImages.add(cleanUrl);
    }

    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      images: cleanImages,
      creationAt: DateTime.parse(json['creationAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
    );
  }
}

class Category {
  final int id;
  final String name;
  final String image;
  final DateTime creationAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.creationAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['image'] as String;
    // Add "https://" if it's just an Imgur ID
    if (imageUrl.startsWith('imgur.com/')) {
      imageUrl = 'https://' + imageUrl;
    }

    // Handle pravatar.cc URLs
    if (imageUrl.contains('pravatar.cc') &&
        !imageUrl.contains('i.pravatar.cc')) {
      imageUrl = 'https://i.pravatar.cc/300?u=${json['id']}';
    }

    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      image: imageUrl,
      creationAt: DateTime.parse(json['creationAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
