import 'package:flutter_test/flutter_test.dart';
import 'package:health_platform/features/auth/data/demo_auth_repository.dart';
import 'package:health_platform/features/auth/domain/auth_models.dart';

void main() {
  test('neues Abo erhält sofort den aktuellen Zustand (Replay)', () async {
    final repo = DemoAuthRepository();
    repo.emitInitial();

    // Erst NACH der Initial-Emission abonnieren — der alte Broadcast-
    // Bug hätte hier ewig auf einer Loading-Page hängen lassen.
    late AuthStatus first;
    final sub = repo.authState.listen((s) => first = s);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    sub.cancel();
    repo.dispose();

    expect(first, isA<Authenticated>());
    expect((first as Authenticated).user.name, 'Demo-Nutzer');
  });

  test('signOut → AuthAnonymous, signIn → Authenticated', () async {
    final repo = DemoAuthRepository();
    repo.emitInitial();

    final events = <AuthStatus>[];
    final sub = repo.authState.listen(events.add);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    await repo.signOut();
    await repo.signIn(email: 'x@y.z', password: 'secret');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    sub.cancel();
    repo.dispose();

    expect(events, isNotEmpty);
    expect(events.last, isA<Authenticated>());
    expect(events.whereType<AuthAnonymous>(), isNotEmpty);
  });
}
