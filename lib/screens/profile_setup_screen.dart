import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'main_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final UserModel user;

  const ProfileSetupScreen({super.key, required this.user});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  final PageController _pageController = PageController();
  
  List<File> _selectedImages = [];
  File? _profileImage;
  int _currentStep = 0;
  bool _isUploading = false;
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _selectedAge;
  final TextEditingController _careerController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  String? _selectedCity;
  String? _selectedOccupation;
  bool _showCareerField = false;
  bool _showUniversityField = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;
  }

  final List<String> _peruCities = [
    'Lima', 'Arequipa', 'Trujillo', 'Chiclayo', 'Piura', 'Iquitos', 'Cusco',
    'Chimbote', 'Huancayo', 'Tacna', 'Ica', 'Juliaca', 'Cajamarca', 'Pucallpa',
    'Sullana', 'Ayacucho', 'Chincha Alta', 'Huánuco', 'Tarapoto', 'Puno'
  ];

  final List<String> _occupations = ['Trabajo', 'Estudio'];
  final List<String> _careers = [
    'Administración', 'Arquitectura', 'Arte', 'Biología', 'Comunicaciones',
    'Contabilidad', 'Derecho', 'Economía', 'Educación', 'Enfermería',
    'Ingeniería Civil', 'Ingeniería Industrial', 'Ingeniería de Sistemas',
    'Marketing', 'Medicina', 'Psicología', 'Turismo', 'Veterinaria', 'Otro'
  ];
  
  final List<String> _universities = [
    'Universidad Nacional Mayor de San Marcos', 'Universidad de Lima',
    'Pontificia Universidad Católica del Perú', 'Universidad San Martín de Porres',
    'Universidad Peruana Cayetano Heredia', 'Universidad del Pacífico',
    'Universidad Ricardo Palma', 'Universidad Inca Garcilaso de la Vega',
    'Universidad Tecnológica del Perú', 'Universidad César Vallejo',
    'Universidad Privada del Norte', 'Universidad Continental',
    'Universidad Nacional de Ingeniería', 'Universidad Nacional Agraria',
    'TECSUP', 'SENATI', 'Instituto San Ignacio de Loyola',
    'Instituto Toulouse Lautrec', 'CIBERTEC', 'Otro'
  ];
  
  final List<String> _ages = List.generate(63, (index) => (index + 18).toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _currentStep > 0 ? AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _previousStep,
        ),
        title: Text('¡Hola ${widget.user.firstName}!', 
          style: const TextStyle(color: Colors.white)),
      ) : AppBar(
        backgroundColor: Colors.transparent,
        title: Text('¡Hola ${widget.user.firstName}!', 
          style: const TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildWelcomeStep(),
          _buildNameEditStep(),
          _buildProfilePhotoStep(),
          _buildGalleryPhotosStep(),
          _buildPersonalInfoStep(),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.waving_hand, color: Colors.white, size: 80),
          const SizedBox(height: 30),
          Text(
            '¡Bienvenido ${widget.user.firstName} ${widget.user.lastName}!',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Vamos a configurar tu perfil para que otros usuarios puedan conocerte mejor',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          _buildContinueButton(() => _nextStep()),
        ],
      ),
    );
  }

  Widget _buildNameEditStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Confirma tu información',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Puedes editar tu nombre si es necesario',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          TextField(
            controller: _firstNameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nombre',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          TextField(
            controller: _lastNameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Apellidos',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          
          const Spacer(),
          
          if (_firstNameController.text.isNotEmpty && _lastNameController.text.isNotEmpty)
            _buildContinueButton(() => _nextStep()),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Elige tu foto de perfil',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Esta será la primera imagen que vean otros usuarios',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          GestureDetector(
            onTap: _pickProfileImage,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                image: _profileImage != null 
                  ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover)
                  : null,
              ),
              child: _profileImage == null 
                ? const Icon(Icons.add_a_photo, color: Colors.white, size: 50)
                : null,
            ),
          ),
          
          const Spacer(),
          
          if (_profileImage != null)
            _buildContinueButton(() => _nextStep()),
        ],
      ),
    );
  }

  Widget _buildGalleryPhotosStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Añade tus mejores fotos',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sube al menos 3 fotos para mostrar tu personalidad',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                if (index < _selectedImages.length) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(_selectedImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return GestureDetector(
                    onTap: _pickGalleryImages,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: const Icon(Icons.add, color: Colors.white30, size: 30),
                    ),
                  );
                }
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          if (_selectedImages.length >= 3)
            _buildContinueButton(() => _nextStep()),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Información personal',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          
          DropdownButtonFormField<String>(
            value: _selectedAge,
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Edad',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            items: _ages.map((age) => DropdownMenuItem(
              value: age,
              child: Text(age),
            )).toList(),
            onChanged: (value) => setState(() => _selectedAge = value),
          ),
          
          const SizedBox(height: 20),
          
          DropdownButtonFormField<String>(
            value: _selectedCity,
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Ciudad en Perú',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            items: _peruCities.map((city) => DropdownMenuItem(
              value: city,
              child: Text(city),
            )).toList(),
            onChanged: (value) => setState(() => _selectedCity = value),
          ),
          
          const SizedBox(height: 20),
          
          DropdownButtonFormField<String>(
            value: _selectedOccupation,
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: '¿A qué te dedicas?',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            items: _occupations.map((occupation) => DropdownMenuItem(
              value: occupation,
              child: Text(occupation),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _selectedOccupation = value;
                _showCareerField = value == 'Estudio';
                if (!_showCareerField) {
                  _careerController.clear();
                  _universityController.clear();
                  _showUniversityField = false;
                }
              });
            },
          ),
          
          if (_showCareerField) ...[
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _careerController.text.isEmpty ? null : _careerController.text,
              dropdownColor: Colors.grey[800],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '¿Qué carrera estudias?',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              items: _careers.map((career) => DropdownMenuItem(
                value: career,
                child: Text(career),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _careerController.text = value ?? '';
                  _showUniversityField = _careerController.text.isNotEmpty;
                  if (!_showUniversityField) {
                    _universityController.clear();
                  }
                });
              },
            ),
            if (_showUniversityField) ...[
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _universityController.text.isEmpty ? null : _universityController.text,
                dropdownColor: Colors.grey[800],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: '¿En qué universidad o instituto estudias?',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                items: _universities.map((university) => DropdownMenuItem(
                  value: university,
                  child: Text(university),
                )).toList(),
                onChanged: (value) => setState(() => _universityController.text = value ?? ''),
              ),
            ],
          ],
          
          const Spacer(),
          
          if (_isFormValid())
            _buildContinueButton(_completeProfile),
        ],
      ),
    );
  }

  Widget _buildContinueButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isUploading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: _isUploading 
          ? const CircularProgressIndicator(color: Colors.black)
          : const Text('Continuar', style: TextStyle(color: Colors.black, fontSize: 16)),
      ),
    );
  }

  void _nextStep() {
    setState(() => _currentStep++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = File(image.path));
    }
  }

  Future<void> _pickGalleryImages() async {
    if (_selectedImages.length >= 6) return;
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImages.add(File(image.path)));
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  bool _isFormValid() {
    final basicInfoValid = _selectedAge != null && 
                          _selectedCity != null && 
                          _selectedOccupation != null;
    
    if (_showCareerField) {
      final careerValid = _careerController.text.isNotEmpty;
      if (_showUniversityField) {
        return basicInfoValid && careerValid && _universityController.text.isNotEmpty;
      }
      return basicInfoValid && careerValid;
    }
    
    return basicInfoValid;
  }

  Future<void> _completeProfile() async {
    setState(() => _isUploading = true);
    
    try {
      String? profileImageUrl;
      List<String> photoUrls = [];
      
      // Temporary: Skip image uploads due to Firebase Storage configuration issue
      // TODO: Fix Firebase Storage configuration and re-enable image uploads
      
      String occupation = _selectedOccupation ?? '';
      if (_showCareerField && _careerController.text.isNotEmpty) {
        occupation = '${_selectedOccupation} - ${_careerController.text}';
        if (_showUniversityField && _universityController.text.isNotEmpty) {
          occupation += ' en ${_universityController.text}';
        }
      }
      
      final updatedUser = widget.user.copyWith(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        profileImageUrl: profileImageUrl,
        photoUrls: photoUrls,
        age: int.tryParse(_selectedAge ?? ''),
        city: _selectedCity,
        occupation: _selectedOccupation,
        career: _showCareerField ? _careerController.text : null,
        university: _showUniversityField ? _universityController.text : null,
        isProfileComplete: true,
      );
      
      await _userService.updateUser(updatedUser);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<String> _uploadImage(File image, String fileName) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance
          .ref()
          .child('users/${widget.user.uid}/${fileName}_$timestamp.jpg');
      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _careerController.dispose();
    _universityController.dispose();
    super.dispose();
  }
}