import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../../controllers/cart_provider.dart';
import '../../data/models/product_model.dart';

class DetailScreen extends StatefulWidget {
  final Product product;
  final String heroTag;

  const DetailScreen({
    super.key,
    required this.product,
    required this.heroTag,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentPage = 0;
  final double _expandedHeight = 400.h;
  final List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
    _initializeImages();
  }

  void _initializeImages() {
    _imageUrls.addAll(widget.product.images);
    if (_imageUrls.isEmpty) {
      _imageUrls.add(widget.product.category.image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) => Opacity(
            opacity: _animation.value,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: _expandedHeight,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Iconsax.arrow_left),
                    onPressed: _handleBack,
                  ),
                  actions: [
                    Consumer<CartProvider>(
                      builder: (context, cart, _) {
                        final isInCart =
                            cart.items.containsKey(widget.product.id);
                        return Stack(
                          children: [
                            IconButton(
                              icon: Icon(
                                isInCart
                                    ? Iconsax.shopping_cart5
                                    : Iconsax.shopping_cart,
                                color: isInCart
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                              onPressed: () {
                                cart.addItem(widget.product);
                                Fluttertoast.showToast(
                                  msg: isInCart
                                      ? 'Quantity increased'
                                      : 'Added to cart',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  textColor: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                );
                              },
                            ),
                            if (isInCart)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: EdgeInsets.all(4.r),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${cart.items[widget.product.id]?.quantity ?? 0}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
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
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: widget.heroTag,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemCount: _imageUrls.length,
                            itemBuilder: (context, index) {
                              return _ImageWithFallback(
                                imageUrl: _imageUrls[index],
                                fallbackUrls: _imageUrls.sublist(index + 1),
                                categoryImage: widget.product.category.image,
                              );
                            },
                          ),
                          if (_imageUrls.length > 1)
                            Positioned(
                              bottom: 16.h,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _imageUrls.length,
                                  (index) => Container(
                                    width: 8.w,
                                    height: 8.w,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 4.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentPage == index
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24.r),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.product.title,
                                      style: TextStyle(
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: Text(
                                      '\$${widget.product.price}',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant
                                      .withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Text(
                                  widget.product.category.name,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                widget.product.description,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey[300],
                                ),
                              ),
                              SizedBox(height: 24.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: _InfoTile(
                                      icon: Iconsax.calendar_1,
                                      label: 'Created',
                                      value: _formatDate(
                                          widget.product.creationAt),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: _InfoTile(
                                      icon: Iconsax.refresh,
                                      label: 'Updated',
                                      value:
                                          _formatDate(widget.product.updatedAt),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),
                              SizedBox(
                                width: double.infinity,
                                child: Consumer<CartProvider>(
                                  builder: (context, cart, _) {
                                    final isInCart = cart.items
                                        .containsKey(widget.product.id);
                                    return FilledButton.icon(
                                      onPressed: () {
                                        cart.addItem(widget.product);
                                        Fluttertoast.showToast(
                                          msg: isInCart
                                              ? 'Quantity increased'
                                              : 'Added to cart',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          textColor: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        );
                                      },
                                      style: FilledButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16.h),
                                      ),
                                      icon: Icon(
                                        isInCart
                                            ? Iconsax.shopping_cart5
                                            : Iconsax.shopping_cart,
                                      ),
                                      label: Text(
                                        isInCart ? 'Add More' : 'Add to Cart',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
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
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _handleBack() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.pop(context);
    }
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16.r,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageWithFallback extends StatefulWidget {
  final String imageUrl;
  final List<String> fallbackUrls;
  final String categoryImage;

  const _ImageWithFallback({
    required this.imageUrl,
    required this.fallbackUrls,
    required this.categoryImage,
  });

  @override
  State<_ImageWithFallback> createState() => _ImageWithFallbackState();
}

class _ImageWithFallbackState extends State<_ImageWithFallback> {
  late Future<String> _workingImageFuture;

  @override
  void initState() {
    super.initState();
    _workingImageFuture = _findWorkingImage();
  }

  Future<String> _findWorkingImage() async {
    try {
      final image = NetworkImage(widget.imageUrl);
      final stream = image.resolve(ImageConfiguration.empty);
      final completer = Completer<void>();
      late ImageStreamListener listener;

      listener = ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete();
          stream.removeListener(listener);
        },
        onError: (dynamic exception, StackTrace? stackTrace) {
          stream.removeListener(listener);
          completer.completeError(exception);
        },
      );

      stream.addListener(listener);

      await completer.future;
      return widget.imageUrl;
    } catch (_) {
      // Try fallback images
      for (final fallbackUrl in widget.fallbackUrls) {
        try {
          final image = NetworkImage(fallbackUrl);
          final stream = image.resolve(ImageConfiguration.empty);
          final completer = Completer<void>();
          late ImageStreamListener listener;

          listener = ImageStreamListener(
            (ImageInfo info, bool _) {
              completer.complete();
              stream.removeListener(listener);
            },
            onError: (dynamic exception, StackTrace? stackTrace) {
              stream.removeListener(listener);
              completer.completeError(exception);
            },
          );

          stream.addListener(listener);

          await completer.future;
          return fallbackUrl;
        } catch (_) {
          continue;
        }
      }

      // If all else fails, return category image
      return widget.categoryImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _workingImageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
            highlightColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
            child: Container(
              color: Colors.white,
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: const Icon(Iconsax.image),
          );
        }

        return CachedNetworkImage(
          imageUrl: snapshot.data!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
            highlightColor:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
            child: Container(
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: const Icon(Iconsax.image),
          ),
        );
      },
    );
  }
}
