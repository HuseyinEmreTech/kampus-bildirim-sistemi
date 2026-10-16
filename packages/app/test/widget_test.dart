import 'package:campus_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CampusApp shows title', (tester) async {
    await tester.pumpWidget(const CampusApp());

    expect(find.text('Campus Report'), findsOneWidget);
    expect(find.text('Uygulama giriş noktası hazırlanıyor'), findsOneWidget);
  });
}
