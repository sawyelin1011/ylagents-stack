/// The core identity genome of an Agent.
///
/// These fields define *what* the agent is and *how* it behaves,
/// beyond the technical model configuration stored in [Assistant].
///
/// Fields:
///   [identity] — Who the agent is (e.g. "a senior software engineer")
///   [soul] — Core personality, values, and "why" (e.g. "crafts clean,
///     test-driven code and mentors junior developers")
///   [role] — The specific function/job (e.g. "code reviewer and
///     architecture advisor")
///   [goals] — What this agent aims to achieve (e.g. "improve code
///     quality, enforce best practices, reduce technical debt")
///   [backstory] — Optional narrative context (e.g. "Built three
///     production microservices at a fintech startup")
class AgentGenome {
  /// Who the agent is (identity/archetype).
  final String identity;

  /// Core personality, values, and drive.
  final String soul;

  /// The agent's specific function or job title.
  final String role;

  /// What the agent aims to achieve.
  final List<String> goals;

  /// Optional narrative backstory / origin.
  final String backstory;

  const AgentGenome({
    this.identity = '',
    this.soul = '',
    this.role = '',
    this.goals = const <String>[],
    this.backstory = '',
  });

  bool get isEmpty =>
      identity.isEmpty &&
      soul.isEmpty &&
      role.isEmpty &&
      goals.isEmpty &&
      backstory.isEmpty;

  AgentGenome copyWith({
    String? identity,
    String? soul,
    String? role,
    List<String>? goals,
    String? backstory,
    bool clearIdentity = false,
    bool clearSoul = false,
    bool clearRole = false,
    bool clearGoals = false,
    bool clearBackstory = false,
  }) {
    return AgentGenome(
      identity: clearIdentity ? '' : (identity ?? this.identity),
      soul: clearSoul ? '' : (soul ?? this.soul),
      role: clearRole ? '' : (role ?? this.role),
      goals: clearGoals ? const <String>[] : (goals ?? this.goals),
      backstory: clearBackstory ? '' : (backstory ?? this.backstory),
    );
  }

  Map<String, dynamic> toJson() => {
    if (identity.isNotEmpty) 'identity': identity,
    if (soul.isNotEmpty) 'soul': soul,
    if (role.isNotEmpty) 'role': role,
    if (goals.isNotEmpty) 'goals': goals,
    if (backstory.isNotEmpty) 'backstory': backstory,
  };

  factory AgentGenome.fromJson(Map<String, dynamic> json) => AgentGenome(
    identity: (json['identity'] as String?) ?? '',
    soul: (json['soul'] as String?) ?? '',
    role: (json['role'] as String?) ?? '',
    goals:
        (json['goals'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        const <String>[],
    backstory: (json['backstory'] as String?) ?? '',
  );

  static const AgentGenome empty = AgentGenome();
}
