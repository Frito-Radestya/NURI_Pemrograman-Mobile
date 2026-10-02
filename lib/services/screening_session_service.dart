/// Sesi skrining kader (F-08): kumpulkan banyak anak dalam satu Posyandu + rekap.
class ScreeningSession {
  final String id;
  final String kaderUserId;
  final String posyanduName;
  final DateTime date;
  final List<String> childIds;

  ScreeningSession({
    required this.id,
    required this.kaderUserId,
    required this.posyanduName,
    required this.date,
    List<String>? childIds,
  }) : childIds = childIds ?? [];
}

class SessionRecap {
  final int total;
  final int normal;
  final int perluPemantauan;
  final int risiko;
  final List<String> followUpChildIds;
  const SessionRecap({
    required this.total,
    required this.normal,
    required this.perluPemantauan,
    required this.risiko,
    required this.followUpChildIds,
  });
}

class ScreeningSessionService {
  static final ScreeningSessionService _instance =
      ScreeningSessionService._internal();
  factory ScreeningSessionService() => _instance;
  ScreeningSessionService._internal();

  final Map<String, ScreeningSession> _sessions = {};
  int _counter = 0;

  List<ScreeningSession> forKader(String kaderUserId) {
    final list = _sessions.values
        .where((s) => s.kaderUserId == kaderUserId)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  ScreeningSession create({
    required String kaderUserId,
    required String posyanduName,
  }) {
    if (posyanduName.trim().isEmpty) {
      throw ArgumentError('Nama Posyandu wajib diisi.');
    }
    _counter++;
    final s = ScreeningSession(
      id: 'sess_${DateTime.now().millisecondsSinceEpoch}_$_counter',
      kaderUserId: kaderUserId,
      posyanduName: posyanduName.trim(),
      date: DateTime.now(),
    );
    _sessions[s.id] = s;
    return s;
  }

  void addChild(String sessionId, String childId) {
    final s = _sessions[sessionId];
    if (s == null) throw StateError('Sesi tidak ditemukan.');
    if (!s.childIds.contains(childId)) s.childIds.add(childId);
  }

  void removeChild(String sessionId, String childId) {
    _sessions[sessionId]?.childIds.remove(childId);
  }

  /// Rekap berdasar status profil anak terkini (disinkron saat Simpan skrining).
  SessionRecap recap(
    String sessionId,
    String Function(String childId) statusOf,
  ) {
    final s = _sessions[sessionId];
    if (s == null) throw StateError('Sesi tidak ditemukan.');
    var normal = 0, perlu = 0, risiko = 0;
    final followUp = <String>[];
    for (final id in s.childIds) {
      switch (statusOf(id)) {
        case 'Normal':
          normal++;
          break;
        case 'Risiko Stunting':
          risiko++;
          followUp.add(id);
          break;
        default:
          perlu++;
          followUp.add(id);
      }
    }
    return SessionRecap(
      total: s.childIds.length,
      normal: normal,
      perluPemantauan: perlu,
      risiko: risiko,
      followUpChildIds: followUp,
    );
  }

  void clear() => _sessions.clear();
}
