import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: widget.child,
    );
  }
}

Widget horizontalLoadingListBuilder(Widget child, {int? length}) {
  return ShimmerLoading(
    isLoading: true,
    child: length == 1
        ? child
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                length ?? 4,
                (index) =>
                    Padding(padding: EdgeInsets.only(right: 10), child: child),
              ),
            ),
          ),
  );
}

Widget verticalLoadingListBuilder(Widget child, {int? length, double? space}) {
  return ShimmerLoading(
    isLoading: true,
    child: length == 1
        ? child
        : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: List.generate(
                length ?? 4,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: space ?? 10),
                  child: child,
                ),
              ),
            ),
          ),
  );
}

// Widget gridLoadingListBuilder(Widget child, {EdgeInsets? padding}) {
//   return ShimmerLoading(
//       isLoading: true,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Padding(
//           padding: padding ?? const EdgeInsets.all(0),
//           child: CustomeGrideWidget(
//             children: List.generate(8, (index) => child),
//           ),
//         ),
//       ));
// }
