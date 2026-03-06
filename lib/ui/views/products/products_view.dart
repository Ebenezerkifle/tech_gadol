import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_gadol/app/responsive_helper.dart';
import 'package:tech_gadol/models/dimensions.dart';
import 'package:tech_gadol/models/product.dart';
import 'package:tech_gadol/ui/common/app_colors.dart';
import 'package:tech_gadol/ui/views/product_detail/product_detail_view.dart';
import 'package:tech_gadol/ui/views/products/products_view_notifier.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tech_gadol/ui/widgets/category_chip.dart';
import 'package:tech_gadol/ui/widgets/product_card.dart';
import 'package:tech_gadol/ui/widgets/shimmer_loading.dart';

import '../../../models/product_category.dart';

class ProductsView extends ConsumerStatefulWidget {
  const ProductsView({super.key});

  @override
  ConsumerState<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends ConsumerState<ProductsView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productsViewProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsViewProvider);
    final notifier = ref.read(productsViewProvider.notifier);

    final bool isTab = ResponsiveHelper.isTab(context);

    final masterList = Column(
      children: [
        _buildSearchBar(notifier),
        // if (state.categories.isNotEmpty && !state.isLoadingInitial)
        _buildCategoryList(notifier),
        Expanded(child: _buildBody(notifier, isTab)),
      ],
    );

    return Scaffold(
      appBar: isTab
          ? AppBar(title: const Text('Tech Gadol - Products'))
          : AppBar(title: const Text('Products')),
      body: isTab
          ? Row(
              children: [
                SizedBox(
                  width: 180.w, // Fixed width for master list on tablets
                  child: masterList,
                ),
                // const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: state.maybeWhen(
                    loaded: (_, _, _, _, selectedProductId, _, _) =>
                        selectedProductId != null
                        ? ProductDetailView(
                            key: ValueKey(selectedProductId),
                            productId: selectedProductId,
                          )
                        : Center(
                            child: Text(
                              'Select a product to view details.',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(color: darkGrey),
                            ),
                          ),
                    orElse: () => Center(
                      child: Text(
                        'Select a product to view details.',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: darkGrey),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : masterList,
    );
  }

  Widget _buildSearchBar(ProductsViewNotifier notifier) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    notifier.setSearchQuery('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: lightGrey.withOpacity(0.5)),
          ),
          filled: true,
          fillColor: backgroundColor,
        ),
        onSubmitted: (value) => notifier.setSearchQuery(value),
        onChanged: (value) {
          // You could debounce here to avoid too many requests
        },
      ),
    );
  }

  Widget _buildCategoryList(ProductsViewNotifier notifier) {
    final state = ref.watch(productsViewProvider);

    return SizedBox(
      height: 40.h,
      child: state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: horizontalLoadingListBuilder(
            CategoryChip(category: 'Category', isSelected: true, onTap: () {}),
          ),
        ),
        error: (_) => const SizedBox.shrink(),
        empty: (categories, selectedCategory, _, _) =>
            _categoryListBuilder(categories, selectedCategory, notifier),
        loaded: (_, categories, selectedCategory, _, _, _, _) =>
            _categoryListBuilder(categories, selectedCategory, notifier),
      ),
    );
  }

  Widget _categoryListBuilder(
    List<ProductCategory> categories,
    ProductCategory? selectedCategory,
    ProductsViewNotifier notifier,
  ) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          final isSelected = selectedCategory == null;
          return CategoryChip(
            category: 'All',
            isSelected: isSelected,
            onTap: () => notifier.setCategory(null),
          );
        }
        final category = categories[index - 1];
        final isSelected = selectedCategory == category;
        return CategoryChip(
          category: category.name ?? '',
          isSelected: isSelected,
          onTap: () => notifier.setCategory(category),
        );
      },
    );
  }

  Widget _buildBody(ProductsViewNotifier notifier, bool isTab) {
    final state = ref.watch(productsViewProvider);

    return state.when(
      initial: () => _buildLoadingList(),
      loading: () => _buildLoadingList(),
      error: (message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16.h),
            Text(message),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => notifier.retry(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      // ignore: unnecessary_underscores
      empty: (_, __, ___, ____) =>
          const Center(child: Text('No products found.')),
      // ignore: unnecessary_underscores
      loaded: (products, _, __, ___, ____, isFetchingMore, hasMore) {
        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
          itemCount: products.length + (isFetchingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == products.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final product = products[index];
            return ProductCard(
              product: product,
              imageSize: isTab ? 60.w : null,
              onTap: () {
                if (!isTab) {
                  context.push('/products/${product.id}');
                } else {
                  notifier.setSelectedProductId(product.id.toString());
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
      child: verticalLoadingListBuilder(
        space: 5.h,
        ProductCard(
          product: Product(
            id: 1,
            title: 'title',
            description: 'description',
            category: 'category',
            price: 0.00,
            discountPercentage: 0.00,
            rating: 0.0,
            stock: 0,
            tags: [],
            sku: 'sku',
            weight: 0,
            dimensions: Dimensions(width: 0.0, height: 0.0, depth: 0.0),
            warrantyInformation: 'warrantyInformation',
            shippingInformation: 'shippingInformation',
            availabilityStatus: 'availabilityStatus',
            reviews: [],
            returnPolicy: 'returnPolicy',
            minimumOrderQuantity: 0,
            images: [],
            thumbnail: '',
          ),
        ),
      ),
    );
  }
}
