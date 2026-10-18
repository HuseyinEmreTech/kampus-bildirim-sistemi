/// İki durumlu sonuç: başarılı [Success] ya da başarısız [Failure].
sealed class Result<S, F> {
  const Result();

  T map<T>(T Function(S value) onSuccess, T Function(F error) onFailure);
}

final class Success<S, F> extends Result<S, F> {
  const Success(this.value);

  final S value;

  @override
  T map<T>(T Function(S value) onSuccess, T Function(F error) onFailure) =>
      onSuccess(value);
}

final class Failure<S, F> extends Result<S, F> {
  const Failure(this.error);

  final F error;

  @override
  T map<T>(T Function(S value) onSuccess, T Function(F error) onFailure) =>
      onFailure(error);
}
