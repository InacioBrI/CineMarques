import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'movie_detail_page.dart';
import 'login.dart';
import 'register.dart';

class MovieListPage extends StatefulWidget {
  MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  final DatabaseService _databaseService = DatabaseService();

  final TextEditingController _searchController = TextEditingController();
  String _selectedGenre = 'All';

  static const List<String> _genresFilter = [
    'All',
    'Action',
    'Adventure',
    'Comedy',
    'Horror',
    'Romance',
    'Sci-Fi',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _databaseService.moviesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Erro ao carregar filmes',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum filme cadastrado. Adicione documentos na coleção "movies" no Firestore.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final movies = docs
              .map((d) => d.data())
              .map((data) => {
                    'title': data['title'] as String? ?? 'Sem título',
                    'description': data['description'] as String? ?? '',
                    'imageUrl': data['imageUrl'] as String? ?? '',
                    'genre': (data['genre'] as String?) ?? 'Outros',
                  })
              .toList();

          final search = _searchController.text.trim().toLowerCase();

          final filtered = movies.where((movie) {
            final title = (movie['title'] as String).toLowerCase();
            final genre = movie['genre'] as String;

            final matchesSearch = search.isEmpty || title.contains(search);
            final matchesGenre = _selectedGenre == 'All' || genre == _selectedGenre;

            return matchesSearch && matchesGenre;
          }).toList();

          final heroMovie = filtered.isNotEmpty ? filtered.first : movies.first;

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner de destaque
                  _HeroBanner(movie: heroMovie),

                  const SizedBox(height: 16),

                  // Barra de busca
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xff1c1c1e),
                        hintText: 'Search...',
                        hintStyle:
                            const TextStyle(color: Colors.white54, fontSize: 14),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Filtro por gênero (chips)
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _genresFilter.length,
                      itemBuilder: (context, index) {
                        final genre = _genresFilter[index];
                        final selected = genre == _selectedGenre;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(genre),
                            selected: selected,
                            onSelected: (_) {
                              setState(() => _selectedGenre = genre);
                            },
                            selectedColor: Colors.white,
                            labelStyle: TextStyle(
                              color: selected ? Colors.black : Colors.white,
                            ),
                            backgroundColor: const Color(0xff1c1c1e),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Título "Popular Movies"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Popular Movies',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final movie = filtered[index];
                        return _PopularMovieCard(movie: movie);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final Map<String, dynamic> movie;

  const _HeroBanner({required this.movie});

  @override
  Widget build(BuildContext context) {
    final title = movie['title'] as String? ?? 'Sem título';
    final imageUrl = movie['imageUrl'] as String? ?? '';

    return GestureDetector(
      onTap: () async {
        final authService = Provider.of<AuthService>(context, listen: false);
        final user = authService.currentUser;

        if (user == null) {
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Faça seu cadastro'),
              content: const Text(
                  'Você precisa estar logado para acessar os detalhes do filme.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text('Cadastrar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text('Já tenho conta'),
                ),
              ],
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailPage(
              title: title,
              description: movie['description'] as String? ?? '',
              imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
            ),
          ),
        );
      },
      child: Container(
        height: 260,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.movie,
                            size: 60, color: Colors.white54),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.movie,
                        size: 60, color: Colors.white54),
                  ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final authService =
                          Provider.of<AuthService>(context, listen: false);
                      final user = authService.currentUser;

                      if (user == null) {
                        await showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Faça seu cadastro'),
                            content: const Text(
                                'Você precisa estar logado para acessar os detalhes do filme.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                    ),
                                  );
                                },
                                child: const Text('Cadastrar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: const Text('Já tenho conta'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailPage(
                            title: title,
                            description:
                                movie['description'] as String? ?? '',
                            imageUrl:
                                imageUrl.isNotEmpty ? imageUrl : null,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play Trailer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularMovieCard extends StatelessWidget {
  final Map<String, dynamic> movie;

  const _PopularMovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    final title = movie['title'] as String? ?? 'Sem título';
    final imageUrl = movie['imageUrl'] as String? ?? '';

    return GestureDetector(
      onTap: () async {
        final authService = Provider.of<AuthService>(context, listen: false);
        final user = authService.currentUser;

        if (user == null) {
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Faça seu cadastro'),
              content: const Text(
                  'Você precisa estar logado para acessar os detalhes do filme.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text('Cadastrar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text('Já tenho conta'),
                ),
              ],
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailPage(
              title: title,
              description: movie['description'] as String? ?? '',
              imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
            ),
          ),
        );
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[900],
                            child: const Icon(Icons.broken_image,
                                color: Colors.white54),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.movie,
                            color: Colors.white54),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
