import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Coleções
  CollectionReference get usersRef => _db.collection('users');
  CollectionReference get moviesRef => _db.collection('movies');
  CollectionReference get restaurantsRef => _db.collection('restaurants');

  // Usuário: nome, email, fotoUrl
  Future<void> upsertUser({
    required String uid,
    required String name,
    required String email,
    required String? photoUrl,
  }) async {
    await usersRef.doc(uid).set({
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // Filmes: título, descrição, imagemUrl
  Future<void> addMovie({
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    await moviesRef.add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> moviesStream() {
    return _db
        .collection('movies')
        .orderBy('createdAt', descending: false)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data() ?? {},
          toFirestore: (data, _) => data,
        )
        .snapshots();
  }

  // Restaurantes: nome, categoria, imagem, tempo estimado, distância
  Future<void> addRestaurant({
    required String name,
    required String category,
    required String imageUrl,
    required String tempo,
    required String distancia,
  }) async {
    await restaurantsRef.add({
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'tempo': tempo,
      'distancia': distancia,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> restaurantsStream() {
    return _db
        .collection('restaurants')
        .orderBy('createdAt', descending: false)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => snap.data() ?? {},
          toFirestore: (data, _) => data,
        )
        .snapshots();
  }
}
