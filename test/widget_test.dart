import 'package:flutter_test/flutter_test.dart';

import 'package:fit_track/main.dart';

void main() {
  testWidgets('FitTrack authentication screen loads successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FitTrackApp());

    // AuthGate should show LoginScreen
    // when there is no logged-in user.
    expect(find.text('Welcome to FitTrack'), findsOneWidget);

    expect(find.text('Login to track your fitness journey'), findsOneWidget);

    expect(find.text('Login'), findsOneWidget);

    expect(find.text('Create Account'), findsOneWidget);
  });
}
