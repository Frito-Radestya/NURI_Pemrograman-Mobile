import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../shared/widgets.dart';
import 'consultation_widgets.dart';

class NakesChatScreen extends ConsumerStatefulWidget {
  const NakesChatScreen({super.key, required this.item});

  final NakesItem item;

  @override
  ConsumerState<NakesChatScreen> createState() => _NakesChatScreenState();
}

class _NakesChatScreenState extends ConsumerState<NakesChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  static const _quickPromptsMother = [
    'Tanya Reaksi Susu / MPASI',
    'Konsultasi Berat Badan Anak',
    'Keluhan Kehamilan & TTD',
  ];

  static const _quickPromptsNakes = [
    'Sudah diminum TTD/susunya hari ini Bun?',
    'Silakan datang ke Posyandu/Puskesmas untuk kontrol ya Bun.',
    'Tetap pantau porsi protein hewani Si Kecil ya Bunda.',
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text, {required bool isCadre, required String userName}) {
    final clean = text.trim();
    if (clean.isEmpty) return;
    final notifier = ref.read(appControllerProvider.notifier);
    notifier.sendChatMessage(
      nakesId: widget.item.id,
      text: clean,
      senderRole: isCadre ? 'nakes' : 'mother',
      senderName: isCadre ? widget.item.name : userName,
    );
    _input.clear();
    if (!isCadre) {
      // Auto-reply simulasi respons bidan/dokter bila belum ada balasan dari nakes
      final existing =
          ref.read(appControllerProvider).chatMessages[widget.item.id] ??
          const [];
      if (existing.length <= 2) {
        Future<void>.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          notifier.sendChatMessage(
            nakesId: widget.item.id,
            text:
                'Terima kasih pesannya Bunda $userName. Saya ${widget.item.name} sudah menerima catatan Ibu, mari kita pantau bersama ya.',
            senderRole: 'nakes',
            senderName: widget.item.name,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final isCadre = state.isCadre;
    final userName = state.currentUser?.name.split(' ').first ?? 'Bunda';
    final messages = state.chatMessages[widget.item.id] ?? const [];
    final prompts = isCadre ? _quickPromptsNakes : _quickPromptsMother;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            AppAvatar(
              name: widget.item.name,
              size: 38,
              index: widget.item.name.length % 8,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          isCadre
                              ? 'Mode Balasan Bidan / Nakes • Online'
                              : '${widget.item.role} • Online',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryFixed.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.softMint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monitor_heart_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.facility,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        widget.item.specialty,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh.withValues(
                        alpha: 0.6,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Text(
                      'Ruang Konsultasi Terenkripsi NURI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ChatBubble(
                  senderName: widget.item.name,
                  text:
                      'Assalamualaikum Bunda. Selamat datang di layanan konsultasi NURI (${widget.item.facility}). Silakan sampaikan keluhan atau pertanyaan seputar kehamilan & tumbuh kembang Si Kecil.',
                  time: '08:00 WIB',
                  isMe: isCadre,
                ),
                ...messages.map((m) {
                  final fromNakes = m['senderRole'] == 'nakes';
                  final isMe = isCadre ? fromNakes : !fromNakes;
                  return _ChatBubble(
                    senderName: m['senderName'] ?? '',
                    text: m['text'] ?? '',
                    time: m['time'] ?? 'Baru saja',
                    isMe: isMe,
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              14,
              8,
              14,
              MediaQuery.paddingOf(context).bottom + 10,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: prompts
                        .map(
                          (prompt) => Padding(
                            padding: const EdgeInsets.only(right: 6, bottom: 8),
                            child: ActionChip(
                              label: Text(
                                prompt,
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              onPressed: () {
                                _input.text = prompt;
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (val) =>
                            _send(val, isCadre: isCadre, userName: userName),
                        decoration: InputDecoration(
                          hintText: isCadre
                              ? 'Balas pesan sebagai ${widget.item.name.split(',').first}...'
                              : 'Tulis pesan untuk ${widget.item.name.split(',').first}...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            borderSide: const BorderSide(color: AppColors.line),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            borderSide: const BorderSide(color: AppColors.line),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _send(
                        _input.text,
                        isCadre: isCadre,
                        userName: userName,
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          gradient: AppGradients.button,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.senderName,
    required this.text,
    required this.time,
    required this.isMe,
  });

  final String senderName;
  final String text;
  final String time;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primaryFixed.withValues(alpha: 0.45)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          border: Border.all(
            color: isMe
                ? AppColors.primaryFixedDim.withValues(alpha: 0.5)
                : AppColors.line,
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  senderName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
