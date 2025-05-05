import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  late CameraController _controller;
  bool _isInitializing = true;
  String? _lastDetectedCard;
  bool _isScanning = false;
  final _textRecognizer = TextRecognizer();
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _stopScanning();
    _controller.dispose();
    _textRecognizer.close();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.back),
        ResolutionPreset.high,
      );
      await _controller.initialize();
      setState(() => _isInitializing = false);
      _startScanning();
    } catch (e) {
      debugPrint('Camera error: $e');
      setState(() => _isInitializing = false);
    }
  }

  void _startScanning() {
    if (_isScanning) return;
    setState(() => _isScanning = true);
    _scanTimer = Timer.periodic(const Duration(seconds: 1), (_) => _captureAndScan());
  }

  void _stopScanning() {
    _scanTimer?.cancel();
    setState(() => _isScanning = false);
  }

  Future<void> _captureAndScan() async {
    if (!_isScanning || !_controller.value.isInitialized) return;

    try {
      final image = await _controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Buscar texto que parezca nombre de carta Magic
      final potentialNames = _extractPotentialCardNames(recognizedText);
      
      if (potentialNames.isNotEmpty && mounted) {
        setState(() {
          _lastDetectedCard = potentialNames.first;
        });
      }
    } catch (e) {
      debugPrint('Scan error: $e');
    }
  }

  List<String> _extractPotentialCardNames(RecognizedText recognizedText) {
    final potentialNames = <String>[];
    final magicCardNamePattern = RegExp(r'^[A-Z][a-zA-Z\s\-]{3,}$');

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final text = line.text.trim();
        if (text.length > 3 && 
            text.length < 30 && 
            magicCardNamePattern.hasMatch(text)) {
          potentialNames.add(text);
        }
      }
    }
    return potentialNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Cartas Magic'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.pause : Icons.play_arrow),
            onPressed: _isScanning ? _stopScanning : _startScanning,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isInitializing
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      CameraPreview(_controller),
                      _buildCardOutline(),
                    ],
                  ),
          ),
          if (_lastDetectedCard != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black.withOpacity(0.7),
              child: Text(
                _lastDetectedCard!,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardOutline() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Alinea la carta dentro del marco',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}