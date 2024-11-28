import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              if (cart.itemCount > 0) {
                return IconButton(
                  icon: const Icon(Iconsax.trash),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear Cart'),
                        content: const Text(
                            'Are you sure you want to remove all items?'),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          TextButton(
                            child: const Text('Clear'),
                            onPressed: () {
                              cart.clear();
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.itemCount == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.shopping_cart,
                    size: 64.r,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Add items to get started',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items.values.elementAt(index);
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 16.r),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Iconsax.trash,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                      onDismissed: (_) => cart.removeItem(item.productId),
                      child: Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.1),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.r),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: CachedNetworkImage(
                                  imageUrl: item.image,
                                  width: 80.w,
                                  height: 80.w,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                    child: const Icon(Iconsax.image),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '\$${item.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Iconsax.add_circle),
                                    onPressed: () =>
                                        cart.incrementQuantity(item.productId),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Iconsax.minus_cirlce),
                                    onPressed: () =>
                                        cart.decrementQuantity(item.productId),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${cart.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Checkout functionality coming soon!'),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                          ),
                          icon: const Icon(Iconsax.shopping_bag),
                          label: Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
