import 'package:flutter/material.dart';

/// Colores oficiales por tipo de Pokémon.
const Map<String, Color> kTypeColors = {
  'normal': Color(0xFFA8A77A),
  'fire': Color(0xFFEE8130),
  'water': Color(0xFF6390F0),
  'electric': Color(0xFFF7D02C),
  'grass': Color(0xFF7AC74C),
  'ice': Color(0xFF96D9D6),
  'fighting': Color(0xFFC22E28),
  'poison': Color(0xFFA33EA1),
  'ground': Color(0xFFE2BF65),
  'flying': Color(0xFFA98FF3),
  'psychic': Color(0xFFF95587),
  'bug': Color(0xFFA6B91A),
  'rock': Color(0xFFB6A136),
  'ghost': Color(0xFF735797),
  'dragon': Color(0xFF6F35FC),
  'dark': Color(0xFF705746),
  'steel': Color(0xFFB7B7CE),
  'fairy': Color(0xFFD685AD),
};

/// Traducciones al español para mostrar en la UI.
const Map<String, String> kTypeNamesEs = {
  'normal': 'Normal',
  'fire': 'Fuego',
  'water': 'Agua',
  'electric': 'Eléctrico',
  'grass': 'Planta',
  'ice': 'Hielo',
  'fighting': 'Lucha',
  'poison': 'Veneno',
  'ground': 'Tierra',
  'flying': 'Volador',
  'psychic': 'Psíquico',
  'bug': 'Bicho',
  'rock': 'Roca',
  'ghost': 'Fantasma',
  'dragon': 'Dragón',
  'dark': 'Siniestro',
  'steel': 'Acero',
  'fairy': 'Hada',
};

const Map<String, String> kStatNamesEs = {
  'hp': 'PS',
  'attack': 'Ataque',
  'defense': 'Defensa',
  'special-attack': 'Atq. Esp.',
  'special-defense': 'Def. Esp.',
  'speed': 'Velocidad',
};

/// Elemento ligero usado para la lista/búsqueda
class PokemonSummary {
  final int id;
  final String name;

  PokemonSummary({required this.id, required this.name});

  factory PokemonSummary.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final segments = url.split('/').where((s) => s.isNotEmpty).toList();
    final id = int.parse(segments.last);
    return PokemonSummary(id: id, name: json['name'] as String);
  }

  String get displayName =>
      name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);

  String get idLabel => '#${id.toString().padLeft(3, '0')}';

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  String get thumbnailUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
}

/// Información completa de un Pokémon
class Pokemon {
  final int id;
  final String name;
  final int heightDm; // decímetros
  final int weightHg; // hectogramos
  final List<String> types;
  final List<String> abilities;
  final Map<String, int> stats;
  final String? spriteOfficial;
  final String? spriteDefault;

  Pokemon({
    required this.id,
    required this.name,
    required this.heightDm,
    required this.weightHg,
    required this.types,
    required this.abilities,
    required this.stats,
    this.spriteOfficial,
    this.spriteDefault,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final typesList = (json['types'] as List)
        .map((t) => t['type']['name'] as String)
        .toList();

    final abilitiesList = (json['abilities'] as List)
        .map((a) => a['ability']['name'] as String)
        .toList();

    final statsMap = <String, int>{};
    for (final s in (json['stats'] as List)) {
      statsMap[s['stat']['name'] as String] = s['base_stat'] as int;
    }

    final sprites = json['sprites'] as Map<String, dynamic>?;
    final other = sprites?['other'] as Map<String, dynamic>?;
    final officialArtwork = other?['official-artwork'] as Map<String, dynamic>?;

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      heightDm: json['height'] as int,
      weightHg: json['weight'] as int,
      types: typesList,
      abilities: abilitiesList,
      stats: statsMap,
      spriteOfficial: officialArtwork?['front_default'] as String?,
      spriteDefault: sprites?['front_default'] as String?,
    );
  }

  String get displayName =>
      name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);

  String get idLabel => '#${id.toString().padLeft(3, '0')}';

  double get heightMeters => heightDm / 10.0;

  double get weightKg => weightHg / 10.0;

  String get imageUrl =>
      spriteOfficial ??
      spriteDefault ??
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  Color get primaryColor =>
      types.isNotEmpty ? (kTypeColors[types.first] ?? Colors.grey) : Colors.grey;

  String typeNameEs(String type) => kTypeNamesEs[type] ?? type;

  String statNameEs(String stat) => kStatNamesEs[stat] ?? stat;

  String abilityNameEs(String ability) =>
      ability.split('-').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
}
