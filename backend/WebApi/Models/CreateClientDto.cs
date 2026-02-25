namespace WebApi.Models;

public class CreateClientDto
{
    public required string Name { get; set; }
    public required string Phone { get; set; }
    public string? Extra { get; set; }
}
