using Google.Cloud.Firestore;
using Microsoft.AspNetCore.Mvc;
using WebApi.Models;

namespace WebApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ClientsController(FirestoreDb firestoreDb) : ControllerBase
    {
        private readonly FirestoreDb _firestoreDb = firestoreDb;

        [HttpPost]
        public async Task<IActionResult> CreateClient([FromBody] CreateClientDto clientDto)
        {
            try
            {
                CollectionReference collection = _firestoreDb.Collection("clients");

                Dictionary<string, object?> clientData = new()
                {
                    { "name", clientDto.Name },
                    { "phone", clientDto.Phone },
                    { "extra", clientDto.Extra },
                    { "createdAt", Timestamp.GetCurrentTimestamp() },
                };

                DocumentReference docRef = await collection.AddAsync(clientData);

                ResponseClientDto responseClientDto = new()
                {
                    Id = docRef.Id,
                    Name = clientDto.Name,
                    Phone = clientDto.Phone,
                    Extra = clientDto.Extra,
                };

                return CreatedAtAction(
                    nameof(CreateClient),
                    new { id = docRef.Id },
                    responseClientDto
                );
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteClient(string id)
        {
            try
            {
                DocumentReference docRef = _firestoreDb.Collection("clients").Document(id);

                DocumentSnapshot snapshot = await docRef.GetSnapshotAsync();

                if (!snapshot.Exists)
                {
                    return NotFound(new { message = "Client not found" });
                }

                await docRef.DeleteAsync();

                return Ok();
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Delete Error: {ex.Message}");
            }
        }
    }
}
