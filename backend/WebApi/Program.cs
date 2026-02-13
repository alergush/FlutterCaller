using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Google.Cloud.Firestore;
using Google.Cloud.Firestore.V1;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();
builder.Services.AddControllers();

string path = Path.Combine(AppContext.BaseDirectory, "firebase_key.json");

if (!File.Exists(path))
{
    throw new Exception("firebase_key.json not found");
}

var firebaseProjectId = builder.Configuration["Firebase:ProjectId"];

if (string.IsNullOrWhiteSpace(firebaseProjectId))
{
    throw new Exception("Firebase ProjectId not found in appsettings.json");
}

GoogleCredential credential;

using (var stream = new FileStream(path, FileMode.Open, FileAccess.Read))
{
    var serviceAccount = ServiceAccountCredential.FromServiceAccountData(stream);
    credential = GoogleCredential.FromServiceAccountCredential(serviceAccount);
}

if (FirebaseApp.DefaultInstance == null)
{
    FirebaseApp.Create(new AppOptions() { Credential = credential });
}

builder.Services.AddSingleton(_ =>
{
    var clientBuilder = new FirestoreClientBuilder { Credential = credential };
    var client = clientBuilder.Build();

    return FirestoreDb.Create(firebaseProjectId, client);
});

builder.Services.AddCors(options =>
{
    options.AddPolicy(
        "AllowAll",
        policy =>
        {
            policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
        }
    );
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

// app.UseHttpsRedirection();

app.UseCors("AllowAll");

app.MapControllers();

app.Run();
