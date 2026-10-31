using Npgsql;

namespace RaporIstatistik;

/// <summary>
/// Çekirdekle aynı <c>DATABASE_URL</c> biçimini
/// (<c>postgres://kullanici:parola@host:5432/campus?sslmode=disable</c>)
/// Npgsql bağlantı dizesine çevirir.
/// </summary>
public static class DatabaseUrl
{
    public static string ToConnectionString(string? url)
    {
        if (string.IsNullOrWhiteSpace(url)
            || !Uri.TryCreate(url, UriKind.Absolute, out var uri)
            || uri.Scheme is not ("postgres" or "postgresql"))
        {
            throw new InvalidOperationException(
                "DATABASE_URL postgres://kullanici:parola@host:port/veritabani biçiminde olmalı.");
        }

        var userInfo = uri.UserInfo.Split(':', 2);
        var builder = new NpgsqlConnectionStringBuilder
        {
            Host = uri.Host,
            Port = uri.IsDefaultPort || uri.Port < 0 ? 5432 : uri.Port,
            Database = uri.AbsolutePath.TrimStart('/'),
            Username = Uri.UnescapeDataString(userInfo[0]),
            Password = userInfo.Length > 1 ? Uri.UnescapeDataString(userInfo[1]) : null,
            // Salt okunur oturum: bu servis veritabanına yazamaz (ADR-04).
            Options = "-c default_transaction_read_only=on",
        };
        if (uri.Query.Contains("sslmode=disable", StringComparison.OrdinalIgnoreCase))
        {
            builder.SslMode = SslMode.Disable;
        }

        return builder.ConnectionString;
    }
}
