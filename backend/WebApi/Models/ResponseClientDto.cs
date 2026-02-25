using System;

namespace WebApi.Models;

public class ResponseClientDto
{
    public required string Id { get; set; }
    public required string Name { get; set; }
    public required string Phone { get; set; }
    public string? Extra { get; set; }
}
