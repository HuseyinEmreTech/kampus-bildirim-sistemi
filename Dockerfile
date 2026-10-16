# Sunucu imajı (canlı ortam için, compose.prod.yaml kullanır).
# Derleme aşamasında sunucu tek dosyalık programa çevrilir; çalışan imajda yalnızca
# o program ve Dart'ın çalışma kütüphaneleri olur: Dart SDK, kaynak kod, kabuk yok.
FROM docker.io/library/dart:3.13.5 AS derleme
WORKDIR /kaynak

# Yalnızca sunucunun ihtiyacı olan paketler kopyalanır (.env, .git vb. imaja girmez).
COPY pubspec.yaml pubspec.lock ./
COPY packages/domain packages/domain
COPY packages/application packages/application
COPY packages/contracts packages/contracts
COPY packages/infrastructure packages/infrastructure
COPY packages/server packages/server

# packages/app bir Flutter paketi; bu imajda Flutter yok ve sunucu ona bağlı değil.
RUN sed -i '/^  - packages\/app$/d' pubspec.yaml && dart pub get
RUN mkdir -p /cikti/files \
  && dart compile exe packages/server/bin/server.dart -o /cikti/server

FROM scratch
COPY --from=derleme /runtime/ /
COPY --from=derleme /cikti/server /app/server
# Fotoğraf klasörü; compose.prod.yaml buraya kalıcı disk bağlar.
COPY --from=derleme --chown=65534:65534 /cikti/files /data/files

# root olarak çalışmaz: 65534 hiçbir yetkisi olmayan "nobody" kullanıcısıdır.
USER 65534:65534
EXPOSE 8080
ENTRYPOINT ["/app/server"]
