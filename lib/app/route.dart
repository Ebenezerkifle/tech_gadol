import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tech_gadol/ui/views/products/products_view.dart';
import 'package:tech_gadol/ui/views/product_detail/product_detail_view.dart';

import '../ui/views/error_view.dart';

final GlobalKey<NavigatorState> rootNavKey = GlobalKey<NavigatorState>();

final Provider<GoRouter> goRouterProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (BuildContext context, GoRouterState state) =>
        ErrorView(error: state.error.toString()),
    navigatorKey: rootNavKey,
    observers: <NavigatorObserver>[],
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const ProductsView(),
      ),
      GoRoute(
        path: '/products/:id',
        builder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id']!;
          return ProductDetailView(productId: id);
        },
      ),
    ],
  );
});
