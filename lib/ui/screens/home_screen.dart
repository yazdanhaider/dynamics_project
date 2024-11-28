import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import '../../controllers/product_provider.dart';
import '../../controllers/cart_provider.dart';
import '../../themes/theme_provider.dart';
import 'detail_screen.dart';
import 'cart_screen.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    Future.microtask(
      () => context.read<ProductProvider>().fetchProducts(),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _handleRefresh() {
    _refreshController.repeat();
    context.read<ProductProvider>().fetchProducts().then((_) {
      _refreshController.stop();
      _refreshController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neura Dynamics'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      cart.itemCount > 0
                          ? Iconsax.shopping_cart5
                          : Iconsax.shopping_cart,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.brush_1),
            onPressed: () => _showThemePicker(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => context
                        .read<ProductProvider>()
                        .updateSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Iconsax.search_normal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Iconsax.sort,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () => _showSortingModal(context),
                  ),
                ),
              ],
            ),
          ),
          Consumer<ProductProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return Container(
                  height: 40.h,
                  margin: EdgeInsets.only(bottom: 8.h),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.r),
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.r),
                        child: Container(
                          height: 32.h,
                          width: 80.w,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Center(
                            child: SizedBox(
                              height: 12.h,
                              width: 12.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }

              if (provider.categories.isEmpty) return const SizedBox.shrink();

              return Container(
                height: 40.h,
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.r),
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final category = provider.categories[index];
                    final isSelected = category == provider.selectedCategory;

                    return Padding(
                      padding: EdgeInsets.only(right: 8.r),
                      child: FilterChip(
                        selected: isSelected,
                        showCheckmark: false,
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            fontSize: 13.sp,
                          ),
                        ),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.8),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        onSelected: (bool selected) {
                          provider.selectCategory(selected ? category : null);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Loading products...',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.wifi_square,
                          size: 48.r,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          provider.error!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        FilledButton.icon(
                          onPressed: _handleRefresh,
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                          ),
                          icon: RotationTransition(
                            turns: _refreshController,
                            child: const Icon(Iconsax.refresh),
                          ),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48.r,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = MediaQuery.of(context).size.width;
                    final horizontalPadding = width > 1200
                        ? width * 0.2
                        : width > 900
                            ? width * 0.1
                            : 0.0;

                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: GridView.builder(
                        padding: EdgeInsets.all(16.r),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: width > 715 ? 3 : 2,
                          mainAxisSpacing: 16.r,
                          crossAxisSpacing: 16.r,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: provider.products.length,
                        itemBuilder: (context, index) {
                          final product = provider.products[index];
                          return _ProductCard(product: product);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Theme Color',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 16.r,
              runSpacing: 16.r,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    ThemeProvider.of(context).updateTheme(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50.r,
                    height: 50.r,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white24,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Consumer<ProductProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        children: SortOption.values.map((option) {
                          final isSelected = provider.currentSort == option;
                          return ListTile(
                            leading: Icon(
                              option.icon,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            title: Text(
                              option.label,
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            onTap: () {
                              provider.setSortOption(option);
                              Navigator.pop(context);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic product;

  const _ProductCard({required this.product});

  Widget _buildImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: product.category.image,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        highlightColor:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
        child: Container(
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) {
        // If category image fails, try product images
        if (product.images.isNotEmpty) {
          return _ProductImagesWidget(images: product.images);
        }
        return Container(
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: const Center(
            child: Icon(Iconsax.image),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String heroTag = 'product-${product.id}';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        DetailScreen(
                      product: product,
                      heroTag: heroTag,
                    ),
                    transitionDuration: const Duration(milliseconds: 300),
                    reverseTransitionDuration:
                        const Duration(milliseconds: 300),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Hero(
                      tag: heroTag,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                          ),
                          child: _buildImage(context),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.all(8.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '\$${product.price}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              product.category.name,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImagesWidget extends StatefulWidget {
  final List<String> images;

  const _ProductImagesWidget({required this.images});

  @override
  State<_ProductImagesWidget> createState() => _ProductImagesWidgetState();
}

class _ProductImagesWidgetState extends State<_ProductImagesWidget> {
  int _currentIndex = 0;

  void _tryNextImage() {
    if (_currentIndex < widget.images.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.images[_currentIndex],
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        highlightColor:
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
        child: Container(
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) {
        _tryNextImage();
        return Shimmer.fromColors(
          baseColor:
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
          highlightColor:
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
          child: Container(
            color: Colors.white,
          ),
        );
      },
    );
  }
}
