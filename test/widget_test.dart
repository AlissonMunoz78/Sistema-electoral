import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_electoral/features/actas/domain/entities/acta.dart';
import 'package:sistema_electoral/features/actas/domain/repositories/acta_repository.dart';
import 'package:sistema_electoral/main.dart';

class FakeActaRepository implements ActaRepository {
  @override
  Future<void> crearActa(Acta acta) async {}

  @override
  Future<List<Acta>> obtenerActas() async => [];
}

void main() {
  testWidgets('muestra la pantalla inicial del sistema electoral', (tester) async {
    await tester.pumpWidget(MyApp(repository: FakeActaRepository()));

    expect(find.text('Sistema Electoral'), findsOneWidget);
    expect(find.text('Mesa receptora del voto'), findsOneWidget);
    expect(find.text('Registrar Acta'), findsOneWidget);
    expect(find.text('Ver Actas'), findsOneWidget);
  });
}
