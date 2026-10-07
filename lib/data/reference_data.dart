import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../domain/models/akg.dart';
import '../domain/models/food_item.dart';
import '../domain/models/growth_status.dart';
import '../domain/models/nutrient.dart';
import '../domain/models/recommendation.dart';
import '../domain/models/who_lms.dart';

/// Aset referensi read-only yang dibundel di APK (PRD Bagian 8).
///
/// `tkpi.json`, `akg.json`, `who_lms.json`, `recommendations.json`.
/// Semua diberi nomor versi dan disimpan pada setiap hasil sebagai
/// `ref_version`.
class ReferenceData {
  const ReferenceData({
    required this.whoLms,
    required this.tkpi,
    required this.akg,
    required this.recommendations,
  });

  final WhoLmsTable whoLms;
  final TkpiCatalog tkpi;
  final AkgCatalog akg;
  final RecommendationCatalog recommendations;

  static const String assetPath = 'assets/data';

  static Future<ReferenceData> load({AssetBundle? bundle}) async {
    final AssetBundle assets = bundle ?? rootBundle;

    final Map<String, dynamic> who = await _readJson(assets, 'who_lms.json');
    final Map<String, dynamic> tkpi = await _readJson(assets, 'tkpi.json');
    final Map<String, dynamic> akg = await _readJson(assets, 'akg.json');
    final Map<String, dynamic> reco =
        await _readJson(assets, 'recommendations.json');

    return ReferenceData(
      whoLms: _parseWho(who),
      tkpi: _parseTkpi(tkpi),
      akg: _parseAkg(akg),
      recommendations: _parseRecommendations(reco),
    );
  }

  static Future<Map<String, dynamic>> _readJson(
    AssetBundle assets,
    String name,
  ) async {
    final String source = await assets.loadString('$assetPath/$name');
    return json.decode(source) as Map<String, dynamic>;
  }

  static WhoLmsTable _parseWho(Map<String, dynamic> json) {
    List<LmsPoint> parse(String key) {
      final List<dynamic> raw = (json[key] as List<dynamic>?) ?? <dynamic>[];
      return raw
          .map(
            (dynamic e) => LmsPoint(
              ageDays: (e['age'] as num).toInt(),
              l: (e['l'] as num).toDouble(),
              m: (e['m'] as num).toDouble(),
              s: (e['s'] as num).toDouble(),
            ),
          )
          .toList();
    }

    return WhoLmsTable(
      refVersion: json['ref_version'] as String? ?? 'unknown',
      boys: parse('boys'),
      girls: parse('girls'),
    );
  }

  static TkpiCatalog _parseTkpi(Map<String, dynamic> json) {
    final List<dynamic> raw = (json['foods'] as List<dynamic>?) ?? <dynamic>[];
    final List<TkpiFood> foods = raw.map((dynamic e) {
      final Map<String, dynamic> map = e as Map<String, dynamic>;
      final Map<String, dynamic> per100 =
          (map['per100g'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final List<dynamic> portions =
          (map['portions'] as List<dynamic>?) ?? <dynamic>[];

      return TkpiFood(
        id: map['id'] as String,
        name: map['name'] as String,
        emoji: map['emoji'] as String? ?? '\u{1F37D}',
        group: map['group'] as String? ?? 'Lainnya',
        per100g: <Nutrient, double>{
          for (final MapEntry<String, dynamic> entry in per100.entries)
            Nutrient.fromJsonKey(entry.key): (entry.value as num).toDouble(),
        },
        portions: portions
            .map(
              (dynamic p) => FoodPortion(
                label: p['label'] as String,
                grams: (p['grams'] as num).toDouble(),
              ),
            )
            .toList(),
      );
    }).toList();

    return TkpiCatalog(
      refVersion: json['ref_version'] as String? ?? 'unknown',
      foods: foods,
    );
  }

  static AkgCatalog _parseAkg(Map<String, dynamic> json) {
    final List<dynamic> raw = (json['groups'] as List<dynamic>?) ?? <dynamic>[];
    final List<AkgGroup> groups = raw.map((dynamic e) {
      final Map<String, dynamic> map = e as Map<String, dynamic>;
      final Map<String, dynamic> targets =
          (map['targets'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      return AkgGroup(
        id: map['id'] as String,
        label: map['label'] as String? ?? '-',
        minAgeMonths: (map['min_age_months'] as num).toInt(),
        maxAgeMonths: (map['max_age_months'] as num).toInt(),
        targets: <Nutrient, double>{
          for (final MapEntry<String, dynamic> entry in targets.entries)
            Nutrient.fromJsonKey(entry.key): (entry.value as num).toDouble(),
        },
      );
    }).toList();

    return AkgCatalog(
      refVersion: json['ref_version'] as String? ?? 'unknown',
      groups: groups,
    );
  }

  static RecommendationCatalog _parseRecommendations(Map<String, dynamic> json) {
    final List<dynamic> raw = (json['items'] as List<dynamic>?) ?? <dynamic>[];
    final List<Recommendation> items = raw.map((dynamic e) {
      final Map<String, dynamic> map = e as Map<String, dynamic>;
      final List<dynamic> actions =
          (map['actions'] as List<dynamic>?) ?? <dynamic>[];
      return Recommendation(
        status: GrowthStatus.fromCode(map['status'] as String?),
        ageBand: map['age_band'] as String? ?? 'under24',
        title: map['title'] as String? ?? '',
        summary: map['summary'] as String? ?? '',
        actions: actions.map((dynamic a) => a as String).toList(),
      );
    }).toList();

    return RecommendationCatalog(
      refVersion: json['ref_version'] as String? ?? 'unknown',
      items: items,
    );
  }
}
