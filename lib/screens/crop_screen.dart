import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'dart:typed_data';

class CropScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final bool isProfile;

  const CropScreen({
    super.key,
    required this.imageBytes,
    required this.isProfile,
  });

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  final CropController _cropController = CropController();

  @override
  void initState() {
    super.initState();
    print('CropScreen iniciado');
  }

  @override
  Widget build(BuildContext context) {
    print('Construyendo CropScreen');
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Recortar imagen', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            print('Cerrando CropScreen');
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              print('Iniciando recorte');
              _cropController.crop();
            },
          ),
        ],
      ),
      body: Crop(
        image: widget.imageBytes,
        controller: _cropController,
        onCropped: (croppedData) {
          print('Imagen recortada, cerrando pantalla');
          SchedulerBinding.instance.addPostFrameCallback((_) {
            final imageBytes = (croppedData as dynamic).bytes as Uint8List;
            Navigator.pop(context, imageBytes);
          });
        },
        aspectRatio: widget.isProfile ? 1.0 : null,
      ),
    );
  }
}