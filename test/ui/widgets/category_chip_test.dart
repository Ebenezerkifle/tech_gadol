import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tech_gadol/ui/widgets/category_chip.dart';
import 'package:tech_gadol/ui/common/app_colors.dart';

void main() {
  group('CategoryChip Widget Tests', () {
    testWidgets('renders category text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: CategoryChip(
                category: 'Smartphones',
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Smartphones'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: CategoryChip(
                category: 'Laptops',
                isSelected: false,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CategoryChip));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('applies selected color styling when isSelected is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: CategoryChip(
                category: 'Tablets',
                isSelected: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.descendant(
        of: find.byType(CategoryChip),
        matching: find.byType(Container),
      ).first);

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(primaryColor));
    });

    testWidgets('applies unselected color styling when isSelected is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: CategoryChip(
                category: 'Tablets',
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.descendant(
        of: find.byType(CategoryChip),
        matching: find.byType(Container),
      ).first);

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(backgroundColor));
    });
  });
}
