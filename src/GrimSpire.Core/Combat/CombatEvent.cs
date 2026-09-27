namespace GrimSpire.Core.Combat;

public enum CombatEventType
{
    Attack,
    CriticalHit,
    Evaded,
    DamageDealt,
    Healed,
    SpecialTriggered,
    UnitDefeated
}

public record CombatEvent
{
    public double TimestampSeconds { get; init; }
    public CombatEventType Type { get; init; }
    public string Source { get; init; } = string.Empty;
    public string Target { get; init; } = string.Empty;
    public double Value { get; init; }
    public string Message { get; init; } = string.Empty;
}

public record CombatResult
{
    public bool PlayerWon { get; init; }
    public double DurationSeconds { get; init; }
    public double TotalDamageDealt { get; init; }
    public double TotalDamageTaken { get; init; }
    public double TotalHealingDone { get; init; }
    public double PlayerEndingHealth { get; init; }
    public IReadOnlyList<CombatEvent> Events { get; init; } = Array.Empty<CombatEvent>();
}
