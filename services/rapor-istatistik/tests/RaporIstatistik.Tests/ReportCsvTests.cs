namespace RaporIstatistik.Tests;

public sealed class ReportCsvTests
{
    [Theory]
    [InlineData(null, "")]
    [InlineData("A Blok", "A Blok")]
    [InlineData("B blok, 2. kat", "\"B blok, 2. kat\"")]
    [InlineData("\"Kütüphane\" önü", "\"\"\"Kütüphane\"\" önü\"")]
    [InlineData("satır\nsonu", "\"satır\nsonu\"")]
    public void Field_EscapesPerRfc4180(string? value, string expected)
    {
        Assert.Equal(expected, ReportCsv.Field(value));
    }

    [Theory]
    [InlineData("=HYPERLINK(\"x\")", "\"'=HYPERLINK(\"\"x\"\")\"")]
    [InlineData("+90 555", "'+90 555")]
    [InlineData("@SUM(A1)", "'@SUM(A1)")]
    public void Field_FormulaStart_IsPrefixedSoExcelDoesNotRunIt(string value, string expected)
    {
        Assert.Equal(expected, ReportCsv.Field(value));
    }

    [Fact]
    public void Line_EmptyOptionalFields_StayEmpty()
    {
        var line = ReportCsv.Line(new ReportExportRow(
            "id-1",
            "Diger",
            "Yeni",
            null,
            null,
            new DateTimeOffset(2026, 10, 24, 22, 0, 0, TimeSpan.FromHours(3)),
            null,
            null));

        Assert.Equal("id-1,Diger,Yeni,,,2026-10-24T19:00:00Z,,\r\n", line);
    }
}
