using Microsoft.AspNetCore.Mvc;
using Twilio.Jwt.AccessToken;

namespace WebApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class VoiceController(IConfiguration configuration) : ControllerBase
    {
        [HttpGet("token")]
        public IActionResult GetToken()
        {
            var accountSid = configuration["Twilio:AccountSid"];
            var apiKey = configuration["Twilio:ApiKey"];
            var apiSecret = configuration["Twilio:ApiSecret"];
            var twimlAppSid = configuration["Twilio:TwimlAppSid"];
            var pushCredentialSid = configuration["Twilio:PushCredentialSid"];
            var tokenExpiration = int.Parse(configuration["Twilio:TokenExpiration"] ?? "3600");

            const string identity = "user_1";

            var grant = new VoiceGrant
            {
                OutgoingApplicationSid = twimlAppSid,
                PushCredentialSid = pushCredentialSid,
                IncomingAllow = true,
            };

            var token = new Token(
                accountSid,
                apiKey,
                apiSecret,
                identity: identity,
                expiration: DateTime.UtcNow.AddSeconds(tokenExpiration),
                grants: [grant]
            );

            Console.WriteLine($"Token generated for: {identity}");

            return Ok(new { token = token.ToJwt(), identity });
        }
    }
}
