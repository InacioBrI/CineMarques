import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload de imagem de perfil
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuário não autenticado');

      final ref = _storage.ref().child('profiles/$userId/profile.jpg');
      
      // Upload do arquivo
      final uploadTask = ref.putFile(imageFile);
      
      // Aguardar conclusão
      final snapshot = await uploadTask.whenComplete(() {});
      
      // Obter URL de download
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Erro ao fazer upload: $e');
      return null;
    }
  }

  // Upload de imagem de filme
  Future<String?> uploadMovieImage(File imageFile, String movieId) async {
    try {
      final ref = _storage.ref().child('movies/$movieId.jpg');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Erro ao fazer upload: $e');
      return null;
    }
  }

  // Deletar imagem
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Erro ao deletar: $e');
      return false;
    }
  }

  // Listar todas as imagens de filmes
  Future<List<String>> listMovieImages() async {
    try {
      final ref = _storage.ref().child('movies');
      final result = await ref.listAll();
      
      List<String> urls = [];
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      print('Erro ao listar imagens: $e');
      return [];
    }
  }
}
