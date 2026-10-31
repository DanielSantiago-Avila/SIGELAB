import 'package:flutter_test/flutter_test.dart';
import 'package:sigelab/main.dart';

void main() {
  testWidgets(
    'SIGELAB inicia correctamente',
    (WidgetTester tester) async {
      // Iniciar la aplicación.
      await tester.pumpWidget(const MyApp());

      // Procesar el primer ciclo de construcción.
      await tester.pump();

      // Verificar que la aplicación se encuentra montada.
      expect(find.byType(MyApp), findsOneWidget);

      // Comprobar que no hubo excepciones durante la construcción.
      expect(tester.takeException(), isNull);
    },
  );
}