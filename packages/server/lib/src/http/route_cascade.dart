import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'json_http.dart';

/// Uç router'larını sırayla dener. Yalnızca adres hiç bulunamadığında
/// ([Router.routeNotFound]) sıradakine geçer; bir ucun kendi 404'ü (ör.
/// "bildirim yok") olduğu gibi döner. Hiçbir router adresi tanımazsa
/// JSON 404 döner (#230).
Handler routeAll(Iterable<Handler> handlers) {
  var cascade = Cascade(shouldCascade: _routeNotFound);
  for (final handler in handlers) {
    cascade = cascade.add(handler);
  }
  return cascade.add(_unknownRoute).handler;
}

bool _routeNotFound(Response response) =>
    identical(response, Router.routeNotFound);

Response _unknownRoute(Request request) =>
    errorResponse(404, 'NOT_FOUND', 'Adres bulunamadı.');
