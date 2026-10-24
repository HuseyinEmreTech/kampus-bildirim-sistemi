using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Tokens;

namespace RaporIstatistik.Tests;

public sealed class ApiFactory : WebApplicationFactory<Program>
{
    /// <summary>Testlere özgü sahte sır; gerçek sır değildir.</summary>
    public const string Secret = "test-access-secret-en-az-otuz-iki-karakter";

    public FakeStats Stats { get; } = new();

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseSetting("JWT_ACCESS_SECRET", Secret);
        builder.ConfigureTestServices(services => services.AddSingleton<IStatsSource>(Stats));
    }
}

public sealed class FakeStats : IStatsSource
{
    public StatsSummary Summary { get; set; } = StatsSummary.From([], null);

    public Task<StatsSummary> GetSummaryAsync(CancellationToken cancel) =>
        Task.FromResult(Summary);
}

public sealed class ApiTests(ApiFactory factory) : IClassFixture<ApiFactory>
{
    [Fact]
    public async Task Health_Returns200()
    {
        var response = await factory.CreateClient().GetAsync("/health");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Summary_WithoutToken_Returns401InCoreErrorFormat()
    {
        var response = await factory.CreateClient().GetAsync("/api/stats/summary");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal("UNAUTHORIZED", body.GetProperty("error").GetProperty("code").GetString());
    }

    [Fact]
    public async Task Summary_StudentToken_Returns403()
    {
        var response = await Get(Token("Student"));

        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task Summary_TokenSignedWithOtherSecret_Returns401()
    {
        var response = await Get(Token("Staff", secret: "baska-bir-access-sirri-en-az-otuz-iki-karakter"));

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Summary_StaffToken_ReturnsSummary()
    {
        factory.Stats.Summary = StatsSummary.From(
            [("Yeni", "Ariza", 2), ("Cozuldu", "Temizlik", 1)],
            3.25);

        var response = await Get(Token("Staff"));

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(3, body.GetProperty("total").GetInt32());
        Assert.Equal(2, body.GetProperty("byStatus").GetProperty("Yeni").GetInt32());
        Assert.Equal(0, body.GetProperty("byStatus").GetProperty("Ustlenildi").GetInt32());
        Assert.Equal(1, body.GetProperty("byCategory").GetProperty("Temizlik").GetInt32());
        Assert.Equal(3.2, body.GetProperty("averageResolutionHours").GetDouble());
    }

    private Task<HttpResponseMessage> Get(string token)
    {
        var client = factory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
        return client.GetAsync("/api/stats/summary");
    }

    /// <summary>Dart çekirdeğinin ürettiği belirtecin aynısı: sub, role, iss.</summary>
    private static string Token(string role, string secret = ApiFactory.Secret) =>
        new JsonWebTokenHandler().CreateToken(new SecurityTokenDescriptor
        {
            Issuer = "campus-report",
            Claims = new Dictionary<string, object>
            {
                ["sub"] = "a0000000-0000-4000-8000-000000000003",
                ["role"] = role,
            },
            Expires = DateTime.UtcNow.AddMinutes(15),
            SigningCredentials = new SigningCredentials(
                new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secret)),
                SecurityAlgorithms.HmacSha256),
        });
}
