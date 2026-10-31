# Çok aşamalı: derleme SDK imajında, çalışma küçük ASP.NET imajında.
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY src/RaporIstatistik/RaporIstatistik.csproj src/RaporIstatistik/
RUN dotnet restore src/RaporIstatistik/RaporIstatistik.csproj
COPY src/ src/
RUN dotnet publish src/RaporIstatistik/RaporIstatistik.csproj \
    -c Release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app .
# İmajın hazır, yetkisiz kullanıcısı; servis root olarak çalışmaz.
USER $APP_UID
EXPOSE 8080
ENTRYPOINT ["dotnet", "RaporIstatistik.dll"]
