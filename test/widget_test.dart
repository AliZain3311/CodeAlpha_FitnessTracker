import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fit_track/main.dart';
import 'package:fit_track/screens/splash_screen.dart';

void main() {
  testWidgets('FitTrack application starts successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FitTrackApp());

    // The application should start with
    // the FitTrack splash screen.
    expect(find.byType(SplashScreen), findsOneWidget);

    // The splash screen should contain
    // the FitTrack splash image.
    expect(find.byType(Image), findsOneWidget);
  });
}
