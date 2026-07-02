import 'package:flutter/material.dart';
import 'package:pokedex/controller/pokemon_api.dart';
import 'package:pokedex/model/pokemon.dart';

class _C {
  static const bg = Color(0xFFF5F5F5);
  static const surface = Colors.white;
  static const border = Color(0xFFE0E0E0);
  static const red = Color(0xFFE3350D);
  static const text = Color(0xFF212121);
  static const textSub = Color(0xFF7A7A7A);
}

class PokemonDetailPage extends StatefulWidget {
  final int id;
  final String name;
  const PokemonDetailPage({super.key, required this.id, required this.name});

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  Pokemon? _pokemon;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final pokemon = await PokemonApi.fetchPokemonDetail(widget.id);
      if (!mounted) return;
      setState(() {
        _pokemon = pokemon;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al obtener datos. Verifica tu conexión.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = _pokemon?.primaryColor ?? _C.red;

    return Scaffold(
      backgroundColor: _C.bg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _C.red))
          : _errorMessage != null
              ? _buildError()
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(headerColor),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(headerColor),
                            const SizedBox(height: 20),
                            _buildInfoCard(),
                            const SizedBox(height: 16),
                            _buildStatsCard(headerColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Column(
      children: [
        AppBar(
          backgroundColor: _C.red,
          leading: const BackButton(color: Colors.white),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 48, color: _C.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _C.text, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(Color color) {
    final imageUrl = _pokemon?.imageUrl;
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: color,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: color.withOpacity(0.9)),
            if (imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 40),
                child: Hero(
                  tag: 'pokemon-${widget.id}',
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.catching_pokemon, color: Colors.white, size: 100),
                  ),
                ),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFFF5F5F5)],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color) {
    final pokemon = _pokemon!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              pokemon.displayName,
              style: const TextStyle(color: _C.text, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Text(
                pokemon.idLabel,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: pokemon.types.map((type) {
            final typeColor = kTypeColors[type] ?? Colors.grey;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pokemon.typeNameEs(type),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final pokemon = _pokemon!;
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.height_rounded, 'Altura', '${pokemon.heightMeters.toStringAsFixed(1)} m'),
          _divider(),
          _infoRow(Icons.monitor_weight_rounded, 'Peso', '${pokemon.weightKg.toStringAsFixed(1)} kg'),
          _divider(),
          _infoRow(
            Icons.auto_awesome_rounded,
            'Habilidades',
            pokemon.abilities.map(pokemon.abilityNameEs).join(', '),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Color color) {
    final pokemon = _pokemon!;
    const maxStat = 180; // referencia visual para las barras
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas base',
            style: TextStyle(color: _C.text, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...pokemon.stats.entries.map((entry) {
            final ratio = (entry.value / maxStat).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pokemon.statNameEs(entry.key),
                        style: const TextStyle(color: _C.textSub, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${entry.value}',
                        style: const TextStyle(color: _C.text, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _C.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _C.red, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _C.textSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: _C.text, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: _C.border, indent: 20, endIndent: 20);
}
