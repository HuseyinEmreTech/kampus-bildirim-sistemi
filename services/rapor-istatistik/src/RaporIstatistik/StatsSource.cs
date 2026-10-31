using Npgsql;

namespace RaporIstatistik;

/// <summary>İstatistiğin kaynağı; testlerde sahtesi takılır.</summary>
public interface IStatsSource
{
    Task<StatsSummary> GetSummaryAsync(CancellationToken cancel);
}

/// <summary>
/// Çekirdeğin PostgreSQL veritabanından yalnızca okur. Bağlantı salt okunur
/// açılır (<see cref="DatabaseUrl"/>); yanlışlıkla yazma sorgusu gitse de reddedilir.
/// </summary>
public sealed class PostgresStatsSource(string connectionString) : IStatsSource, IDisposable
{
    private const string GroupsSql =
        "SELECT status, category, count(*)::int FROM reports GROUP BY status, category";

    private const string AverageSql =
        "SELECT avg(extract(epoch FROM resolved_at - created_at)) / 3600 " +
        "FROM reports WHERE resolved_at IS NOT NULL";

    private readonly NpgsqlDataSource _db = NpgsqlDataSource.Create(connectionString);

    public async Task<StatsSummary> GetSummaryAsync(CancellationToken cancel)
    {
        var groups = new List<(string, string, int)>();
        await using (var command = _db.CreateCommand(GroupsSql))
        await using (var reader = await command.ExecuteReaderAsync(cancel))
        {
            while (await reader.ReadAsync(cancel))
            {
                groups.Add((reader.GetString(0), reader.GetString(1), reader.GetInt32(2)));
            }
        }

        await using var averageCommand = _db.CreateCommand(AverageSql);
        var average = await averageCommand.ExecuteScalarAsync(cancel);
        return StatsSummary.From(
            groups,
            average is null or DBNull ? null : Convert.ToDouble(average));
    }

    public void Dispose() => _db.Dispose();
}
