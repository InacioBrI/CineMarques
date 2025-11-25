import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/image_upload_widget.dart';
import 'register.dart';
import 'login.dart';

class PerfilPage extends StatefulWidget {
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String? _profileImageUrl;
  String? _userName;
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          user != null ? _databaseService.userStream(user.uid) : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = user != null ? snapshot.data?.data() : null;
        _profileImageUrl =
            _profileImageUrl ?? data?['photoUrl'] as String? ?? null;
        _userName = _userName ??
            (data?['name'] as String?) ??
            user?.displayName ??
            'Convidado';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Meu Perfil'),
            backgroundColor: Colors.black,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black,
                  const Color(0xFF3C2DE1).withOpacity(0.8),
                  Colors.black,
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Foto de perfil
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF3C2DE1).withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: const Color(0xFF3C2DE1),
                            child: _profileImageUrl != null
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: _profileImageUrl!,
                                      width: 160,
                                      height: 160,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.person,
                                        size: 80,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF3C2DE1),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white),
                              onPressed: () {
                                // O botão em si não faz upload, o widget abaixo faz
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Nome do usuário
                    Text(
                      _userName ?? 'Convidado',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Email
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                const Color(0xFF3C2DE1).withOpacity(0.3)),
                      ),
                      child: Text(
                        user?.email ?? 'Faça login para ver seu email',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Botão de upload
                    if (user != null) ...[
                      ImageUploadWidget(
                        onImageUploaded: (url) async {
                          setState(() {
                            _profileImageUrl = url;
                          });

                          await _databaseService.upsertUser(
                            uid: user.uid,
                            name:
                                _userName ?? user.displayName ?? 'Usuário',
                            email: user.email ?? '',
                            photoUrl: url,
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Cards de informações
                    if (user != null) ...[
                      _buildInfoCard(
                        icon: Icons.email,
                        title: 'Email verificado',
                        subtitle:
                            user.emailVerified == true ? 'Sim' : 'Não',
                        trailing: Icon(
                          user.emailVerified == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: user.emailVerified == true
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        title: 'Membro desde',
                        subtitle:
                            _formatDate(user.metadata.creationTime),
                        trailing:
                            const Icon(Icons.star, color: Colors.amber),
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        icon: Icons.access_time,
                        title: 'Último acesso',
                        subtitle:
                            _formatDate(user.metadata.lastSignInTime),
                        trailing:
                            const Icon(Icons.login, color: Colors.blue),
                      ),
                      const SizedBox(height: 30),
                    ],

                    if (user != null)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.grey.shade900,
                                title: const Text(
                                  'Confirmar Logout',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  'Deseja realmente sair?',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text(
                                      'Cancelar',
                                      style:
                                          TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'Sair',
                                      style: TextStyle(
                                          color: Color(0xFF3C2DE1)),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await authService.signOut();
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'SAIR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3C2DE1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                    if (user == null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3C2DE1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'FAZER LOGIN / CADASTRO',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF3C2DE1).withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3C2DE1).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF3C2DE1)),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white70),
        ),
        trailing: trailing,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? "mês" : "meses"} atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? "ano" : "anos"} atrás';
    }
  }
}
