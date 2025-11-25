import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/image_upload_widget.dart';
import 'welcome_page.dart';

class CreateProfilePage extends StatefulWidget {
  final String email;
  final String birthDate;
  final String password;

  const CreateProfilePage({
    super.key,
    required this.email,
    required this.birthDate,
    required this.password,
  });

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  String? _photoUrl;
  bool _isLoading = false;

  final DatabaseService _databaseService = DatabaseService();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _finishRegistration() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para o perfil.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await authService.registerWithEmail(
      email: widget.email,
      password: widget.password,
      displayName: name,
    );

    if (error != null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final user = authService.currentUser;
    if (user != null) {
      await _databaseService.upsertUser(
        uid: user.uid,
        name: name,
        email: widget.email,
        photoUrl: _photoUrl,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => WelcomePage(userName: name),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Criar perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Foto de perfil',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ImageUploadWidget(
              onImageUploaded: (url) {
                setState(() => _photoUrl = url);
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nome',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white10,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _finishRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffff0000),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'CONTINUAR',
                        style:
                            TextStyle(color: Colors.white, fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
