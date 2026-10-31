namespace RaporIstatistik.Tests;

public sealed class StatsTests
{
    [Fact]
    public void From_NoReports_AllKeysZeroAndNoAverage()
    {
        var summary = StatsSummary.From([], null);

        Assert.Equal(0, summary.Total);
        Assert.Equal(new[] { "Yeni", "Ustlenildi", "Cozuldu" }, summary.ByStatus.Keys);
        Assert.All(summary.ByCategory.Values, count => Assert.Equal(0, count));
        Assert.Null(summary.AverageResolutionHours);
    }

    [Fact]
    public void From_Groups_SumsByStatusAndCategory()
    {
        var summary = StatsSummary.From(
            [("Yeni", "Ariza", 2), ("Ustlenildi", "Ariza", 1), ("Cozuldu", "Diger", 4)],
            10.04);

        Assert.Equal(7, summary.Total);
        Assert.Equal(3, summary.ByCategory["Ariza"]);
        Assert.Equal(4, summary.ByStatus["Cozuldu"]);
        Assert.Equal(10.0, summary.AverageResolutionHours);
    }

    [Fact]
    public void DatabaseUrl_CoreFormat_BecomesReadOnlyConnectionString()
    {
        var connection = DatabaseUrl.ToConnectionString(
            "postgres://campus:ci%40test@localhost:5433/campus?sslmode=disable");

        Assert.Contains("Host=localhost", connection);
        Assert.Contains("Port=5433", connection);
        Assert.Contains("Database=campus", connection);
        Assert.Contains("Password=ci@test", connection);
        Assert.Contains("SSL Mode=Disable", connection);
        Assert.Contains("default_transaction_read_only=on", connection);
    }

    [Fact]
    public void DatabaseUrl_Missing_Throws()
    {
        Assert.Throws<InvalidOperationException>(() => DatabaseUrl.ToConnectionString(null));
    }
}
