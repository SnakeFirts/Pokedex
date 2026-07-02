import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pokedex/controller/pokemon_api.dart';
import 'package:pokedex/model/pokemon.dart';
import 'package:pokedex/view/pokemon_detail_page.dart';

class _C {
  static const bg = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const border = Color(0xFFE0E0E0);
  static const red = Color(0xFFE3350D);
  static const redDark = Color(0xFFB92B0A);
  static const text = Color(0xFF212121);
  static const textSub = Color(0xFF7A7A7A);
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<PokemonSummary> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  Timer? _debounce;

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
    });

    try {
      final pokemons = await PokemonApi.searchPokemon(query);
      setState(() {
        _results = pokemons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener datos. Verifica tu conexión.';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_searchController.text.trim().isNotEmpty) {
        _search();
      } else {
        setState(() {
          _results = [];
          _hasSearched = false;
          _errorMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.red,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.catching_pokemon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Pokédex',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: _C.red,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: _C.text),
              decoration: InputDecoration(
                hintText: 'Buscar Pokémon por nombre o número...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.85)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _C.red));
    }

    if (_errorMessage != null) {
      return _buildStateMessage(
        icon: Icons.wifi_off_rounded,
        message: _errorMessage!,
      );
    }

    if (!_hasSearched) {
      return _buildStateMessage(
        icon: Icons.catching_pokemon,
        message: 'Ingresa un nombre o número',
        subtitle: 'Busca cualquier Pokémon en la PokéAPI',
      );
    }

    if (_results.isEmpty) {
      return _buildStateMessage(
        icon: Icons.search_off_rounded,
        message: 'No se encontraron Pokémon',
        subtitle: 'Intenta con otro nombre',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) => _PokemonCard(pokemon: _results[index]),
    );
  }

  Widget _buildStateMessage({
    required IconData icon,
    required String message,
    String? subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _C.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: _C.red),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _C.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _C.textSub, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PokemonCard extends StatelessWidget {
  final PokemonSummary pokemon;
  const _PokemonCard({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _C.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PokemonDetailPage(id: pokemon.id, name: pokemon.displayName),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  pokemon.idLabel,
                  style: const TextStyle(
                    color: _C.textSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Hero(
                    tag: 'pokemon-${pokemon.id}',
                    child: Image.network(
                      pokemon.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Image.network(
                        pokemon.thumbnailUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.catching_pokemon,
                          size: 48,
                          color: _C.textSub,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pokemon.displayName,
                style: const TextStyle(
                  color: _C.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
