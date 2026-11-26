import 'package:shelf/shelf.dart';

/// Uç router'larını sırayla dener (#230).
Handler routeAll(Iterable<Handler> handlers) {
  var cascade = Cascade();
  for (final handler in handlers) {
    cascade = cascade.add(handler);
  }
  return cascade.handler;
}
