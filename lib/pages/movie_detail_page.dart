import 'package:flutter/material.dart';
import 'select_session_page.dart';

class MovieDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;

  const MovieDetailPage({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster grande
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.movie,
                            size: 64, color: Colors.black54),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Título e infos rápidas
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                const Text('152 min', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 16),
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                const Text('7.0 IMDb', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),

            // Chips de gênero (fake por enquanto)
            Wrap(
              spacing: 8,
              children: const [
                Chip(
                  label: Text('Action'),
                  backgroundColor: Color(0xffede7ff),
                  labelStyle: TextStyle(color: Color(0xFF3C2DE1)),
                ),
                Chip(
                  label: Text('Sci-Fi'),
                  backgroundColor: Color(0xffe3f2fd),
                  labelStyle: TextStyle(color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Synopsis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description.isNotEmpty
                  ? description
                  : 'No synopsis available for this movie.',
              style: const TextStyle(color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C2DE1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectSessionPage(movieTitle: title),
                    ),
                  );
                },
                child: const Text(
                  'Buy Ticket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
