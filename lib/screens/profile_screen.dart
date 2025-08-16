import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/user_model.dart';
import '../services/confession_service.dart';
import 'confessions_screen.dart';
import 'photo_viewer_screen.dart';
import 'crop_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final ImagePicker _picker = ImagePicker();
  final ConfessionService _confessionService = ConfessionService();
  final ScrollController _scrollController = ScrollController();
  bool _isSelectionMode = false;
  Set<int> _selectedPhotos = {};

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConfessionsScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Error al cargar perfil', style: TextStyle(color: Colors.white)),
            );
          }

          final user = UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
          return _buildProfileContent(user);
        },
      ),
    );
  }

  Widget _buildProfileContent(UserModel user) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileHeader(user),
          const SizedBox(height: 30),
          _buildInfoSection(user),
          const SizedBox(height: 30),
          _buildPhotosSection(user),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                image: user.profileImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(user.profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user.profileImageUrl == null
                  ? const Icon(Icons.person, color: Colors.white, size: 60)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _changeProfilePhoto(user),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${user.firstName} ${user.lastName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.cake, 'Edad', '${user.age ?? 'No especificada'} años'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, 'Ciudad', user.city ?? 'No especificada'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.work, 'Ocupación', user.occupation ?? 'No especificada'),
          if (user.career != null && user.career!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.school, 'Carrera', user.career!),
          ],
          if (user.university != null && user.university!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.account_balance, 'Universidad', user.university!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Mis Fotos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (user.photoUrls.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${user.photoUrls.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  if (user.photoUrls.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: _isSelectionMode ? Colors.red.withOpacity(0.1) : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isSelectionMode ? Icons.close_rounded : Icons.checklist_rounded,
                          color: _isSelectionMode ? Colors.red : Colors.white70,
                          size: 20,
                        ),
                        onPressed: _toggleSelectionMode,
                      ),
                    ),
                  if (_isSelectionMode && _selectedPhotos.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                        onPressed: () => _deleteSelectedPhotos(user),
                      ),
                    ),
                  if (!_isSelectionMode)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_rounded, color: Colors.white70, size: 20),
                        onPressed: () => _addPhoto(user),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          user.photoUrls.isEmpty
              ? Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[800]?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_camera_rounded,
                          color: Colors.white54,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes fotos aún',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Toca + para agregar tu primera foto',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: user.photoUrls.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedPhotos.contains(index);
                    return GestureDetector(
                      onTap: () => _isSelectionMode 
                          ? _togglePhotoSelection(index)
                          : _viewPhoto(user.photoUrls, index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    user.photoUrls[index],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[800],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white54,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          Icons.broken_image_rounded,
                                          color: Colors.white54,
                                          size: 30,
                                        ),
                                      );
                                    },
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isSelectionMode)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: isSelected 
                                      ? Colors.blue.withOpacity(0.3) 
                                      : Colors.black.withOpacity(0.4),
                                ),
                              ),
                            if (_isSelectionMode)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? Colors.blue : Colors.white.withOpacity(0.9),
                                    border: Border.all(
                                      color: isSelected ? Colors.blue : Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                      : null,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Future<void> _changeProfilePhoto(UserModel user) async {
    try {
      print('Iniciando _changeProfilePhoto');
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      print('Imagen seleccionada para perfil: ${image?.path}');
      if (image != null) {
        print('Llamando a _cropImage para perfil');
        final croppedImage = await _cropImage(File(image.path), true);
        print('Imagen de perfil recortada: ${croppedImage != null}');
        if (croppedImage != null) {
          final imageUrl = await _uploadImageBytes(croppedImage, 'profile');
          await _firestore.collection('users').doc(currentUserId).update({
            'profileImageUrl': imageUrl,
          });
        }
      }
    } catch (e) {
      print('Error en _changeProfilePhoto: $e');
    }
  }

  Future<void> _addPhoto(UserModel user) async {
    try {
      print('Iniciando _addPhoto');
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      print('Imagen seleccionada: ${image?.path}');
      if (image != null) {
        print('Llamando a _cropImage');
        final croppedImage = await _cropImage(File(image.path), false);
        print('Imagen recortada recibida: ${croppedImage != null}');
        if (croppedImage != null) {
          final imageUrl = await _uploadImageBytes(croppedImage, 'gallery_${user.photoUrls.length}');
          final updatedPhotos = [...user.photoUrls, imageUrl];
          await _firestore.collection('users').doc(currentUserId).update({
            'photoUrls': updatedPhotos,
          });
        }
      }
    } catch (e) {
      print('Error en _addPhoto: $e');
    }
  }

  Future<Uint8List?> _cropImage(File imageFile, bool isProfile) async {
    try {
      print('Leyendo bytes de imagen');
      final imageBytes = await imageFile.readAsBytes();
      print('Bytes leídos: ${imageBytes.length}');
      
      print('Navegando a CropScreen');
      final result = await Navigator.push<Uint8List>(
        context,
        MaterialPageRoute(
          builder: (context) => CropScreen(
            imageBytes: imageBytes,
            isProfile: isProfile,
          ),
        ),
      );
      print('Resultado de CropScreen: ${result != null}');
      return result;
    } catch (e) {
      print('Error en _cropImage: $e');
      return null;
    }
  }

  Future<String> _uploadImage(File image, String fileName) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('users/$currentUserId/$fileName.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<String> _uploadImageBytes(Uint8List imageBytes, String fileName) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('users/$currentUserId/$fileName.jpg');
    await ref.putData(imageBytes);
    return await ref.getDownloadURL();
  }

  Future<void> _deleteFromStorage(String imageUrl) async {
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
    } catch (e) {
      // Error silencioso
    }
  }

  void _viewPhoto(List<String> photoUrls, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(
          photoUrls: photoUrls,
          initialIndex: initialIndex,
          onDelete: (index) => _deletePhoto(index),
        ),
      ),
    );
  }

  Future<void> _deletePhoto(int index) async {
    try {
      final user = await _firestore.collection('users').doc(currentUserId).get();
      final userData = UserModel.fromMap(user.data() as Map<String, dynamic>);
      final photoUrl = userData.photoUrls[index];
      final updatedPhotos = List<String>.from(userData.photoUrls);
      updatedPhotos.removeAt(index);
      
      await _deleteFromStorage(photoUrl);
      await _firestore.collection('users').doc(currentUserId).update({
        'photoUrls': updatedPhotos,
      });
      
      Navigator.pop(context);
    } catch (e) {
      // Error silencioso
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedPhotos.clear();
    });
  }

  void _togglePhotoSelection(int index) {
    setState(() {
      if (_selectedPhotos.contains(index)) {
        _selectedPhotos.remove(index);
      } else {
        _selectedPhotos.add(index);
      }
    });
  }

  Future<void> _deleteSelectedPhotos(UserModel user) async {
    if (_selectedPhotos.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Eliminar fotos', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Estás seguro de que quieres eliminar ${_selectedPhotos.length} foto(s)?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDeleteSelectedPhotos(user);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteSelectedPhotos(UserModel user) async {
    try {
      final updatedPhotos = List<String>.from(user.photoUrls);
      final sortedIndices = _selectedPhotos.toList()..sort((a, b) => b.compareTo(a));
      
      for (int index in sortedIndices) {
        await _deleteFromStorage(user.photoUrls[index]);
        updatedPhotos.removeAt(index);
      }
      
      await _firestore.collection('users').doc(currentUserId).update({
        'photoUrls': updatedPhotos,
      });
      
      setState(() {
        _isSelectionMode = false;
        _selectedPhotos.clear();
      });
    } catch (e) {
      // Error silencioso
    }
  }
}