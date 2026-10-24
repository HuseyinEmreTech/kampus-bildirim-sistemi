using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using RaporIstatistik;

// Rapor istatistik servisi (ADR-04, #92). Çekirdek veritabanını yalnızca
// okur; giriş Dart çekirdeğinde kalır, burada aynı erişim belirteci doğrulanır.
var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer();
// Ayarlar istek anında okunur; testler kendi sırrını verebilsin.
builder.Services
    .AddOptions<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme)
    .Configure<IConfiguration>(Auth.Configure);
builder.Services.AddAuthorization(options =>
    options.AddPolicy(Auth.StaffPolicy, policy => policy.RequireRole("Staff")));

builder.Services.AddSingleton<IStatsSource>(services =>
    new PostgresStatsSource(DatabaseUrl.ToConnectionString(
        services.GetRequiredService<IConfiguration>()["DATABASE_URL"])));

var app = builder.Build();
app.UseAuthentication();
app.UseAuthorization();

app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

app.MapGet(
        "/api/stats/summary",
        async (IStatsSource stats, CancellationToken cancel) =>
            Results.Ok(await stats.GetSummaryAsync(cancel)))
    .RequireAuthorization(Auth.StaffPolicy);

app.Run();

/// <summary>Testlerin (WebApplicationFactory) uygulamayı bulabilmesi için.</summary>
public partial class Program
{
}

/// <summary>Dart çekirdeğinin ürettiği erişim belirtecini doğrular.</summary>
internal static class Auth
{
    public const string StaffPolicy = "Staff";

    /// <summary>Dart tarafındaki JwtConfig ile aynı değerler.</summary>
    public const string Issuer = "campus-report";
    public const int MinSecretLength = 32;

    public static void Configure(JwtBearerOptions options, IConfiguration config)
    {
        var secret = config["JWT_ACCESS_SECRET"] ?? "";
        if (secret.Length < MinSecretLength)
        {
            throw new InvalidOperationException(
                $"JWT_ACCESS_SECRET en az {MinSecretLength} karakter olmalı.");
        }

        // Belirteçteki "sub" ve "role" adları olduğu gibi kalsın.
        options.MapInboundClaims = false;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = Issuer,
            ValidateAudience = false,
            ValidateLifetime = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret)),
            ValidAlgorithms = [SecurityAlgorithms.HmacSha256],
            NameClaimType = "sub",
            RoleClaimType = "role",
        };
        // Hata gövdesi çekirdekle aynı biçimde: { "error": { code, message, details } }.
        options.Events = new JwtBearerEvents
        {
            OnChallenge = context =>
            {
                context.HandleResponse();
                return ApiErrors.WriteAsync(
                    context.Response, 401, "UNAUTHORIZED", "Giriş yapmanız gerekiyor.");
            },
            OnForbidden = context => ApiErrors.WriteAsync(
                context.Response, 403, "FORBIDDEN", "Bu işlem için yetkiniz yok."),
        };
    }
}

internal static class ApiErrors
{
    public static Task WriteAsync(
        HttpResponse response, int status, string code, string message)
    {
        response.StatusCode = status;
        return response.WriteAsJsonAsync(
            new { error = new { code, message, details = "" } });
    }
}
