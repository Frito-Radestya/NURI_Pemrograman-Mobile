import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../services/child_service.dart';
import '../services/screening_session_service.dart';
import 'stunting_screening_screen.dart';

/// Mode kader: sesi skrining + rekap (F-08).
class ScreeningSessionScreen extends StatefulWidget {
  const ScreeningSessionScreen({super.key});

  @override
  State<ScreeningSessionScreen> createState() => _ScreeningSessionScreenState();
}

class _ScreeningSessionScreenState extends State<ScreeningSessionScreen> {
  final _svc = ScreeningSessionService();
  final _nameCtrl = TextEditingController();

  String get _uid => AuthService().currentUser?.id ?? 'usr_03';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _svc.forKader(_uid);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sesi Skrining Kader',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nama Posyandu / tanggal sesi',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {
              try {
                _svc.create(kaderUserId: _uid, posyanduName: _nameCtrl.text);
                _nameCtrl.clear();
                setState(() {});
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$e'.replaceFirst('Invalid argument(s): ', ''))),
                );
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Buat sesi baru'),
          ),
          const SizedBox(height: 16),
          if (sessions.isEmpty)
            const Text('Belum ada sesi. Buat sesi Posyandu hari ini.')
          else
            ...sessions.map((s) {
              final recap = _svc.recap(
                s.id,
                (id) => ChildService().findById(id)?.status ?? '-',
              );
              return Card(
                child: ExpansionTile(
                  title: Text(s.posyanduName),
                  subtitle: Text(
                    '${s.childIds.length} anak · Normal ${recap.normal} · '
                    'Pantau ${recap.perluPemantauan} · Risiko ${recap.risiko}',
                  ),
                  children: [
                    ...s.childIds.map((id) {
                      final c = ChildService().findById(id);
                      return ListTile(
                        title: Text(c?.name ?? id),
                        subtitle: Text(c?.status ?? '-'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            _svc.removeChild(s.id, id);
                            setState(() {});
                          },
                        ),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final kids = ChildService().getChildren(_uid);
                                final picked = await showDialog<String>(
                                  context: context,
                                  builder: (_) => SimpleDialog(
                                    title: const Text('Pilih anak'),
                                    children: kids
                                        .where((k) => !s.childIds.contains(k.id))
                                        .map((k) => SimpleDialogOption(
                                              onPressed: () => Navigator.pop(context, k.id),
                                              child: Text('${k.name} (${k.status})'),
                                            ))
                                        .toList(),
                                  ),
                                );
                                if (picked != null) {
                                  _svc.addChild(s.id, picked);
                                  setState(() {});
                                }
                              },
                              icon: const Icon(Icons.person_add_outlined),
                              label: const Text('Tambah anak'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StuntingScreeningScreen(),
                                ),
                              ),
                              icon: const Icon(Icons.medical_services_outlined),
                              label: const Text('Skrining'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (recap.followUpChildIds.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Text(
                          'Perlu tindak lanjut: ${recap.followUpChildIds.length} anak. '
                          'Rujuk ke Puskesmas bila z-score < -2.',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
