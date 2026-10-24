using System.Globalization;

namespace RaporIstatistik;

/// <summary>Dışa aktarılan bildirim satırı. Açıklama ve kişi kimlikleri yok.</summary>
public sealed record ReportExportRow(
    string ReportId,
    string Category,
    string Status,
    string? Place,
    string? BuildingId,
    DateTimeOffset CreatedAt,
    DateTimeOffset? TakenAt,
    DateTimeOffset? ResolvedAt);

/// <summary>RFC 4180 biçiminde CSV: virgülle ayrılır, satır sonu CRLF.</summary>
public static class ReportCsv
{
    public const string Header =
        "reportId,category,status,place,buildingId,createdAt,takenAt,resolvedAt\r\n";

    /// <summary>Excel'de formül sanılıp çalıştırılabilecek ilk karakterler.</summary>
    private static readonly char[] FormulaStarts = ['=', '+', '-', '@', '\t', '\r'];

    private static readonly char[] NeedsQuotes = [',', '"', '\r', '\n'];

    public static string Line(ReportExportRow row) =>
        string.Join(
            ',',
            new[]
            {
                row.ReportId,
                row.Category,
                row.Status,
                row.Place,
                row.BuildingId,
                Time(row.CreatedAt),
                Time(row.TakenAt),
                Time(row.ResolvedAt),
            }.Select(Field)) + "\r\n";

    /// <summary>
    /// Tek bir alanı CSV'ye uygun yazar. Formülle başlayan metnin önüne `'`
    /// eklenir (CSV injection): yer tarifine "=..." yazan biri, dosyayı açan
    /// görevlinin Excel'inde komut çalıştıramaz.
    /// </summary>
    public static string Field(string? value)
    {
        if (string.IsNullOrEmpty(value)) return "";
        if (Array.IndexOf(FormulaStarts, value[0]) >= 0) value = "'" + value;
        return value.IndexOfAny(NeedsQuotes) >= 0
            ? "\"" + value.Replace("\"", "\"\"") + "\""
            : value;
    }

    private static string? Time(DateTimeOffset? time) =>
        time?.UtcDateTime.ToString("yyyy-MM-dd'T'HH:mm:ss'Z'", CultureInfo.InvariantCulture);
}
