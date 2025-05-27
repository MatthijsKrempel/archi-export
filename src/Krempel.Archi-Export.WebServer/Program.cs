using Microsoft.AspNetCore.Authorization;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddHealthChecks();

var app = builder.Build();

var defaultFiles = new DefaultFilesOptions
{
    DefaultFileNames = ["index.html"]
};
app.UseDefaultFiles(defaultFiles);
app.UseStaticFiles();
app.UseHttpsRedirection();

app.MapHealthChecks("/health")
    .WithMetadata(new AllowAnonymousAttribute());

app.Run();
