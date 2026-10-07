/// Sesi Posyandu (PRD Bagian 8, `screening_sessions`).
class ScreeningSession {
  const ScreeningSession({
    required this.id,
    required this.kaderId,
    required this.posyanduName,
    required this.heldOn,
    required this.createdAt,
    this.closed = false,
  });

  final String id;
  final String kaderId;
  final String posyanduName;
  final DateTime heldOn;
  final DateTime createdAt;
  final bool closed;

  ScreeningSession copyWith({bool? closed}) => ScreeningSession(
    id: id,
    kaderId: kaderId,
    posyanduName: posyanduName,
    heldOn: heldOn,
    createdAt: createdAt,
    closed: closed ?? this.closed,
  );
}
