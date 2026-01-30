import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nova_commerce/features/product/presentation/product_details_screen.dart';

void main() {
  if (Platform.isWindows) {
    return; // Goldens flaky on Windows due to Flutter tool temp cleanup.
  }

  testWidgets(
    'ProductDetailsScreen (not found) golden',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductDetailsScreen(productId: null),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/product_details_not_found.png'),
      );
    },
    tags: ['golden'],
  );
}
