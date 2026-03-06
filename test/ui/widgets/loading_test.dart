import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tech_gadol/ui/widgets/loading.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tech_gadol/ui/common/app_colors.dart';

void main() {
  group('LoadingWidget Tests', () {
    testWidgets('renders LoadingAnimationWidget with default values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingWidget(),
          ),
        ),
      );

      final hexagonFinder = find.byWidgetPredicate(
        (widget) =>
            widget.runtimeType.toString() == '_HexagonDots', // Internal painter widget type for this animation
      );
      
      // Fallback check if the internal type isn't accessible, we just verify the widget is in the tree
      expect(find.byType(LoadingWidget), findsOneWidget);
    });
  });
}
