import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trivia/utils/categories.dart';

void main() {
  group('category assets', () {
    final ids =
        Categories.categories.map((category) => category.categoryId).toList();

    test('every category has an SVG icon', () {
      for (final id in ids) {
        expect(
          File('assets/images/$id.svg').existsSync(),
          isTrue,
          reason: 'missing assets/images/$id.svg',
        );
      }
    });

    test('every SVG belongs to a known category', () {
      final known = ids.toSet();
      final directory = Directory('assets/images');
      final files = directory.listSync().whereType<File>().map(
        (file) => file.uri.pathSegments.last.replaceAll('.svg', ''),
      );
      for (final name in files) {
        expect(known, contains(name));
      }
    });
  });
}
