import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

// Veritabanı gerektirmeyen birim testler: `Database` işini sahte havuza doğru
// aktarıyor mu? Gerçek PostgreSQL davranışı `database_test.dart`'ta (`db` etiketi).

final _emptyResult = Result(
  rows: const [],
  affectedRows: 3,
  schema: ResultSchema(const []),
);

class _FakeTxSession implements TxSession {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePool implements Pool<Object?> {
  Object? executedQuery;
  Object? executedParameters;
  var transactionStarted = false;
  var wasClosed = false;

  @override
  Future<Result> execute(
    Object query, {
    Object? parameters,
    bool ignoreRows = false,
    QueryMode? queryMode,
    Duration? timeout,
  }) async {
    executedQuery = query;
    executedParameters = parameters;
    return _emptyResult;
  }

  @override
  Future<R> runTx<R>(
    Future<R> Function(TxSession session) fn, {
    Object? locality,
    TransactionSettings? settings,
  }) {
    transactionStarted = true;
    return fn(_FakeTxSession());
  }

  @override
  Future<void> close({bool force = false}) async => wasClosed = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakePool pool;
  late Database db;

  setUp(() {
    pool = _FakePool();
    db = Database(pool);
  });

  test('execute_passesSqlAndParametersToPool', () async {
    final result = await db.execute(r'SELECT $1', [42]);

    expect(pool.executedQuery, r'SELECT $1');
    expect(pool.executedParameters, [42]);
    expect(result.affectedRows, 3);
  });

  test('execute_withoutParameters_sendsEmptyList', () async {
    await db.execute('SELECT 1');

    expect(pool.executedParameters, isEmpty);
  });

  test('transaction_runsActionInsidePoolTransaction', () async {
    final value = await db.transaction((tx) async => 'bitti');

    expect(pool.transactionStarted, isTrue);
    expect(value, 'bitti');
  });

  test('transaction_whenActionThrows_passesErrorOn', () async {
    await expectLater(
      db.transaction<void>((tx) async => throw StateError('hata')),
      throwsStateError,
    );
  });

  test('close_closesPool', () async {
    await db.close();

    expect(pool.wasClosed, isTrue);
  });
}
