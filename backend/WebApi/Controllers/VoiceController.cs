using Microsoft.AspNetCore.Mvc;
using Twilio.Jwt.AccessToken;
using Twilio.TwiML;
using Twilio.TwiML.Voice;

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

            const string operatorId = "operator_1";

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
                identity: operatorId,
                expiration: DateTime.UtcNow.AddSeconds(tokenExpiration),
                grants: [grant]
            );

            Console.WriteLine($"Token generated for: {operatorId}");

            return Ok(new { token = token.ToJwt(), operatorId });
        }

        [HttpPost("incoming")]
        public IActionResult ReceiveIncomingCall()
        {
            var response = new VoiceResponse();
            var dial = new Dial();

            const string targetOperatorId = "operator_1";

            dial.Client(targetOperatorId);
            response.Append(dial);

            return Content(response.ToString(), "application/xml");
        }
    }
}
