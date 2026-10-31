namespace RaporIstatistik;

/// <summary>
/// Bildirim istatistiği. Her durum ve kategori, hiç bildirim olmasa da
/// 0 ile yer alır; istemci eksik anahtar denetlemek zorunda kalmaz.
/// </summary>
public sealed record StatsSummary(
    int Total,
    IReadOnlyDictionary<string, int> ByStatus,
    IReadOnlyDictionary<string, int> ByCategory,
    double? AverageResolutionHours)
{
    /// <summary>Veritabanındaki CHECK kısıtlarıyla aynı değerler.</summary>
    public static readonly string[] Statuses = ["Yeni", "Ustlenildi", "Cozuldu"];

    public static readonly string[] Categories = ["Ariza", "Temizlik", "Guvenlik", "Diger"];

    /// <summary>
    /// (durum, kategori, sayı) gruplarından özeti kurar.
    /// <paramref name="averageResolutionHours"/> çözülen yoksa null.
    /// </summary>
    public static StatsSummary From(
        IEnumerable<(string Status, string Category, int Count)> groups,
        double? averageResolutionHours)
    {
        var byStatus = Statuses.ToDictionary(s => s, _ => 0);
        var byCategory = Categories.ToDictionary(c => c, _ => 0);
        var total = 0;
        foreach (var (status, category, count) in groups)
        {
            byStatus[status] = byStatus.GetValueOrDefault(status) + count;
            byCategory[category] = byCategory.GetValueOrDefault(category) + count;
            total += count;
        }

        var average = averageResolutionHours is { } hours
            ? Math.Round(hours, 1)
            : (double?)null;
        return new StatsSummary(total, byStatus, byCategory, average);
    }
}
