import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/confession_service.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final ConfessionService _confessionService = ConfessionService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final PageController _pageController = PageController();
  final TextEditingController _textController = TextEditingController();
  
  bool _isSending = false;
  int _currentPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildPhotoCarousel(),
          _buildGradientOverlay(),
          _buildContent(),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildPhotoCarousel() {
    final photos = [
      if (widget.user.profileImageUrl != null) widget.user.profileImageUrl!,
      ...widget.user.photoUrls,
    ];

    if (photos.isEmpty) {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.person, color: Colors.white, size: 100),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _currentPhotoIndex = index),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return Image.network(
          photos[index],
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black87,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPhotoIndicators(),
            const SizedBox(height: 20),
            _buildUserInfo(),
            const SizedBox(height: 30),
            _buildConfessionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoIndicators() {
    final photoCount = [
      if (widget.user.profileImageUrl != null) widget.user.profileImageUrl!,
      ...widget.user.photoUrls,
    ].length;

    if (photoCount <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        photoCount,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentPhotoIndex ? Colors.white : Colors.white30,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.user.firstName}, ${widget.user.age ?? '?'}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white70, size: 18),
            const SizedBox(width: 4),
            Text(
              widget.user.city ?? 'Sin especificar',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.work, color: Colors.white70, size: 18),
            const SizedBox(width: 4),
            Text(
              widget.user.occupation ?? 'Sin especificar',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfessionButtons() {
    return SizedBox(
      width: double.infinity,
      child: _buildConfessionButton(
        'Enviar Confesión Anónima',
        Icons.message,
        () => _showTextConfessionDialog(),
      ),
    );
  }

  Widget _buildConfessionButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isSending ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.9),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 50,
      left: 20,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
    );
  }

  void _showTextConfessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Confesión Anónima', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _textController,
          style: const TextStyle(color: Colors.white),
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Escribe tu confesión...',
            hintStyle: TextStyle(color: Colors.white54),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: _sendTextConfession,
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTextConfession() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    Navigator.pop(context);

    try {
      await _confessionService.sendTextConfession(
        currentUserId,
        widget.user.uid,
        _textController.text.trim(),
      );
      
      _textController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confesión enviada anónimamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}