import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex/model/pokemon.dart';

class PokemonApi {
  static const _baseUrl = 'https://pokeapi.co/api/v2';
  static List<PokemonSummary>? _allPokemonCache;

  static Future<List<PokemonSummary>> _loadAllPokemon() async {
    if (_allPokemonCache != null) return _allPokemonCache!;

    final uri = Uri.parse('$_baseUrl/pokemon?limit=1302');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      _allPokemonCache = results
          .map((e) => PokemonSummary.fromJson(e as Map<String, dynamic>))
          .toList();
      return _allPokemonCache!;
    } else {
      throw Exception('Error al conectar con la API (${response.statusCode})');
    }
  }

  /// Busca Pokémon por nombre (parcial) o por número de Pokédex exacto.
  static Future<List<PokemonSummary>> searchPokemon(String query) async {
    final all = await _loadAllPokemon();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final filtered = all
        .where((p) => p.name.contains(q) || p.id.toString() == q)
        .toList();

    filtered.sort((a, b) {
      final aStarts = a.name.startsWith(q) ? 0 : 1;
      final bStarts = b.name.startsWith(q) ? 0 : 1;
      if (aStarts != bStarts) return aStarts - bStarts;
      return a.id.compareTo(b.id);
    });

    return filtered.take(60).toList();
  }

  /// Obtiene el detalle completo de un Pokémon por id.
  static Future<Pokemon> fetchPokemonDetail(int id) async {
    final uri = Uri.parse('$_baseUrl/pokemon/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Pokemon.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Error al obtener datos del Pokémon (${response.statusCode})');
    }
  }
}
