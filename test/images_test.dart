import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:catfacts/assets/ui/assets.dart';

void main() {
  test('images assets test', () {
    expect(File(Images.cat1).existsSync(), true);
    expect(File(Images.cat2).existsSync(), true);
    expect(File(Images.cat3).existsSync(), true);
  });
}
