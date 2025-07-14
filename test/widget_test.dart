import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_cyber_brick_smasher/main.dart';

void main() {
  testWidgets('Start screen shows Start Game button', (tester) async {
    await tester.pumpWidget(const CyberBrickSmasherApp());

    expect(find.text('Start Game'), findsOneWidget);
  });
}
