
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend_biblioteca/main.dart';

void main() {
  testWidgets('App carrega a tela inicial', (WidgetTester tester) async {
    await tester.pumpWidget(const BibliotecaApp());

    expect(find.text('Biblioteca - Livros'), findsOneWidget);
  });
}