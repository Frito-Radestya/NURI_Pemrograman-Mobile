import 'package:flutter_test/flutter_test.dart';
import 'package:stunting_care/services/chatbot_service.dart';

void main() {
  test('Deteksi darurat mengarahkan ke IGD', () async {
    final svc = ChatbotService(apiKey: '');
    expect(ChatbotService.isEmergency('anak kejang dan tidak sadar'), true);
    final reply = await svc.ask('anak kejang');
    expect(reply.toLowerCase(), contains('igd'));
  });

  test('Tanpa key fallback offline tetap menjawab', () async {
    final svc = ChatbotService(apiKey: '');
    expect(svc.hasKey, false);
    final reply = await svc.ask('apa itu mpasi?');
    expect(reply.toLowerCase(), contains('mpasi'));
  });
}
