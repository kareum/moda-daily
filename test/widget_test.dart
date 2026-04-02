import 'package:flutter_test/flutter_test.dart';
import 'package:travel_map_archiver/main.dart';

void main() {
  testWidgets('App smoke test — HomeScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const TravelMapArchiverApp());
    expect(find.text('TravelMap'), findsOneWidget);
  });
}
