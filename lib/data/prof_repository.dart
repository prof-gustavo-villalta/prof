import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

abstract class ProfRepository {
  Future<ProfData> load();

  Future<void> save(ProfData data);
}

class SharedPreferencesProfRepository implements ProfRepository {
  const SharedPreferencesProfRepository();

  static const _key = 'prof.data.v1';

  @override
  Future<ProfData> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const ProfData();
    }
    return ProfData.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }

  @override
  Future<void> save(ProfData data) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, jsonEncode(data.toJson()));
  }
}

class InMemoryProfRepository implements ProfRepository {
  InMemoryProfRepository([this._data = const ProfData()]);

  ProfData _data;

  @override
  Future<ProfData> load() async => _data;

  @override
  Future<void> save(ProfData data) async {
    _data = data;
  }
}
