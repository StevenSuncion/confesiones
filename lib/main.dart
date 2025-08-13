import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECON - Confesiones',
      theme: ThemeData.dark(),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _buttonController;
  late AnimationController _echoController;
  late AnimationController _logoController;
  late Animation<Offset> _titleSlide;
  late Animation<double> _buttonOpacity;
  late Animation<double> _letterE;
  late Animation<double> _letterC;
  late Animation<double> _letterO;
  late Animation<double> _letterN;
  late Animation<double> _echoWaves;
  late Animation<double> _echoFade;
  late Animation<double> _logoOpacity;
  late Animation<double> _staticCircle;
  late Animation<double> _textIcon;
  late Animation<double> _audioIcon;
  late Animation<double> _glitchEffect;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _echoController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _echoWaves = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _echoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _echoFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _echoController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _letterE = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    _letterC = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
    _letterO = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
    _letterN = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.3),
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeIn),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController, 
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _staticCircle = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _echoController,
        curve: const Interval(0.5, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _textIcon = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _echoController,
        curve: const Interval(0.6, 0.7, curve: Curves.easeInOut),
      ),
    );
    
    _audioIcon = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _echoController,
        curve: const Interval(0.7, 0.8, curve: Curves.easeIn),
      ),
    );
    
    _glitchEffect = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeInOut),
      ),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    _echoController.repeat();
    await Future.delayed(const Duration(seconds: 4));
    await _titleController.forward();
    await _buttonController.forward();
    _startLogoAnimation();
  }

  void _startLogoAnimation() async {
    await Future.delayed(const Duration(seconds: 1));
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      await _logoController.forward();
      await Future.delayed(const Duration(seconds: 2));
      await _logoController.reverse();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _buttonController.dispose();
    _echoController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF1a1a1a),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 225,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildEchoWaves(),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _titleController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _titleSlide,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildAnimatedLetter('E', _letterE),
                                  _buildAnimatedLetter('C', _letterC),
                                  _buildAnimatedLetterO(),
                                  _buildAnimatedLetter('N', _letterN),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: AnimatedBuilder(
                      animation: _buttonController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _buttonOpacity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildNeonButton(
                                  'Continuar con Google',
                                  null,
                                  () {},
                                  customIcon: _buildGoogleIcon(),
                                ),
                                const SizedBox(height: 20),
                                _buildNeonButton(
                                  'Continuar con Facebook',
                                  Icons.facebook,
                                  () {},
                                ),
                                const SizedBox(height: 20),
                                _buildNeonButton(
                                  'Continuar con Instagram',
                                  null,
                                  () {},
                                  customIcon: _buildInstagramIcon(),
                                ),
                                const SizedBox(height: 20),
                                _buildNeonButton(
                                  'Continuar con Apple',
                                  null,
                                  () {},
                                  customIcon: _buildAppleIcon(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEchoWaves() {
    return AnimatedBuilder(
      animation: _echoController,
      builder: (context, child) {
        return SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Múltiples ondas concéntricas
              ...List.generate(5, (index) {
                final delay = index * 0.2;
                final waveProgress = (_echoWaves.value - delay).clamp(0.0, 1.0);
                final radius = waveProgress * 125;
                final opacity = (1 - waveProgress) * 0.3;
                
                return Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(opacity),
                      width: 2,
                    ),
                  ),
                );
              }),
              // Círculo estático sin iluminación
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(_staticCircle.value * 0.3),
                    width: 2,
                  ),
                ),
              ),
              // Mostrar solo icono de texto cuando está activo y audio no
              if (_textIcon.value > 0 && _audioIcon.value == 0)
                Icon(
                  Icons.text_fields,
                  color: Colors.white.withOpacity(_textIcon.value),
                  size: 25,
                ),
              // Mostrar solo icono de audio cuando está activo
              if (_audioIcon.value > 0)
                Icon(
                  Icons.mic,
                  color: Colors.white.withOpacity(_audioIcon.value),
                  size: 25,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLetter(String letter, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w100,
              letterSpacing: 8,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.8 * animation.value),
                  blurRadius: 20,
                ),
                Shadow(
                  color: Colors.white.withOpacity(0.4 * animation.value),
                  blurRadius: 40,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLetterO() {
    return AnimatedBuilder(
      animation: Listenable.merge([_letterO, _logoController, _glitchEffect]),
      builder: (context, child) {
        final oOpacity = _letterO.value * (1.0 - (_logoController.value * 2).clamp(0.0, 1.0));
        final glitchIntensity = _glitchEffect.value;
        
        return Opacity(
          opacity: _letterO.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Letra O normal con efecto glitch
              if (glitchIntensity > 0)
                ...List.generate(3, (index) {
                  final offset = (index - 1) * glitchIntensity * 3;
                  final colors = [Colors.red, Colors.green, Colors.blue];
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: Opacity(
                      opacity: oOpacity * 0.7,
                      child: Text(
                        'O',
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w100,
                          letterSpacing: 8,
                          color: colors[index].withOpacity(0.8),
                        ),
                      ),
                    ),
                  );
                }),
              // Letra O normal
              Opacity(
                opacity: oOpacity,
                child: Text(
                  'O',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 8,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.8 * oOpacity),
                        blurRadius: 20,
                      ),
                      Shadow(
                        color: Colors.white.withOpacity(0.4 * oOpacity),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                ),
              ),
              // Logo incógnito estilo fedora y antifaz
              Opacity(
                opacity: _logoOpacity.value,
                child: Container(
                  width: 70,
                  height: 70,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ala del sombrero (forma elíptica)
                      Positioned(
                        top: 15,
                        child: Container(
                          width: 68,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(34),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.8),
                                blurRadius: 20,
                              ),
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.4),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Copa del sombrero (forma trapezoidal)
                      Positioned(
                        top: 0,
                        child: ClipPath(
                          clipper: HatCrownClipper(),
                          child: Container(
                            width: 40,
                            height: 25,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.8),
                                  blurRadius: 20,
                                ),
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  blurRadius: 40,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Lentes de espía mejorados
                      Positioned(
                        top: 32,
                        child: CustomPaint(
                          size: Size(60, 25),
                          painter: SpyGlassesPainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNeonButton(String text, IconData? icon, VoidCallback onPressed, {Widget? customIcon}) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customIcon ?? Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: GoogleIconPainter(),
      ),
    );
  }

  Widget _buildInstagramIcon() {
    return Container(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: InstagramIconPainter(),
      ),
    );
  }

  Widget _buildAppleIcon() {
    return Container(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: AppleIconPainter(),
      ),
    );
  }
}

class SpyGlassesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final centerY = size.height / 2;
    
    // Efecto de iluminado para los lentes
    final glowPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);
    
    // Marco de los lentes (gris)
    final framePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    
    // Cristales (gris claro para mejor visibilidad)
    final lensPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;
    
    // Reflejo en los cristales
    final reflectionPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    // Puente nasal
    final bridgePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;
    
    // Patillas
    final templePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Dibujar cristal izquierdo
    final leftLensRect = Rect.fromCircle(
      center: Offset(center - 18, centerY), 
      radius: 10
    );
    canvas.drawOval(leftLensRect, glowPaint);
    canvas.drawOval(leftLensRect, lensPaint);
    canvas.drawOval(leftLensRect, framePaint);
    
    // Dibujar cristal derecho
    final rightLensRect = Rect.fromCircle(
      center: Offset(center + 18, centerY), 
      radius: 10
    );
    canvas.drawOval(rightLensRect, glowPaint);
    canvas.drawOval(rightLensRect, lensPaint);
    canvas.drawOval(rightLensRect, framePaint);
    
    // Puente nasal (conexión entre lentes)
    final bridgeRect = Rect.fromLTWH(
      center - 8, centerY - 2, 16, 4
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bridgeRect, Radius.circular(2)),
      bridgePaint
    );
    
    // Patilla izquierda
    canvas.drawLine(
      Offset(center - 28, centerY),
      Offset(center - 35, centerY - 3),
      templePaint,
    );
    
    // Patilla derecha
    canvas.drawLine(
      Offset(center + 28, centerY),
      Offset(center + 35, centerY - 3),
      templePaint,
    );
    
    // Reflejos en los cristales
    final leftReflection = Rect.fromCircle(
      center: Offset(center - 21, centerY - 3), 
      radius: 3
    );
    canvas.drawOval(leftReflection, reflectionPaint);
    
    final rightReflection = Rect.fromCircle(
      center: Offset(center + 15, centerY - 3), 
      radius: 3
    );
    canvas.drawOval(rightReflection, reflectionPaint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.08;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    
    // Colores oficiales de Google
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Arco azul (superior)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // -90°
      1.05,  // 60°
      false,
      bluePaint,
    );
    
    // Arco rojo (derecha superior)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.52, // -30°
      1.05,  // 60°
      false,
      redPaint,
    );
    
    // Arco amarillo (derecha inferior)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.52,  // 30°
      1.05,  // 60°
      false,
      yellowPaint,
    );
    
    // Arco verde (izquierda)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.57,  // 90°
      1.57,  // 90°
      false,
      greenPaint,
    );
    
    // Línea horizontal (parte de la G)
    canvas.drawLine(
      Offset(center.dx, center.dy - strokeWidth / 2),
      Offset(center.dx + radius * 0.6, center.dy - strokeWidth / 2),
      bluePaint,
    );
    
    // Línea vertical corta (parte de la G)
    canvas.drawLine(
      Offset(center.dx + radius * 0.6, center.dy - strokeWidth / 2),
      Offset(center.dx + radius * 0.6, center.dy + strokeWidth),
      bluePaint,
    );
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class InstagramIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Cuadrado redondeado exterior
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.1, size.width * 0.8, size.height * 0.8),
      Radius.circular(size.width * 0.2),
    );
    canvas.drawRRect(outerRect, paint);
    
    // Círculo interior (lente)
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.2,
      paint,
    );
    
    // Punto superior derecho
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.25),
      size.width * 0.05,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class AppleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Logo oficial de Apple - forma exacta
    final path = Path();
    
    // Comenzar desde la parte superior
    path.moveTo(size.width * 0.5, size.height * 0.25);
    
    // Curva superior derecha
    path.cubicTo(
      size.width * 0.65, size.height * 0.2,
      size.width * 0.8, size.height * 0.35,
      size.width * 0.78, size.height * 0.55,
    );
    
    // Curva media derecha
    path.cubicTo(
      size.width * 0.76, size.height * 0.7,
      size.width * 0.65, size.height * 0.85,
      size.width * 0.5, size.height * 0.9,
    );
    
    // Curva inferior izquierda
    path.cubicTo(
      size.width * 0.35, size.height * 0.85,
      size.width * 0.24, size.height * 0.7,
      size.width * 0.22, size.height * 0.55,
    );
    
    // Curva superior izquierda
    path.cubicTo(
      size.width * 0.2, size.height * 0.35,
      size.width * 0.35, size.height * 0.2,
      size.width * 0.5, size.height * 0.25,
    );
    
    path.close();
    
    // Dibujar el cuerpo principal
    canvas.drawPath(path, paint);
    
    // Mordida característica de Apple
    final bitePath = Path();
    bitePath.addOval(Rect.fromCircle(
      center: Offset(size.width * 0.7, size.height * 0.4),
      radius: size.width * 0.1,
    ));
    
    // Cortar la mordida
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawPath(path, paint);
    canvas.drawPath(bitePath, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
    
    // Hoja característica
    final leafPath = Path();
    leafPath.moveTo(size.width * 0.52, size.height * 0.25);
    leafPath.cubicTo(
      size.width * 0.58, size.height * 0.12,
      size.width * 0.68, size.height * 0.08,
      size.width * 0.72, size.height * 0.05,
    );
    leafPath.cubicTo(
      size.width * 0.74, size.height * 0.08,
      size.width * 0.7, size.height * 0.15,
      size.width * 0.62, size.height * 0.2,
    );
    leafPath.cubicTo(
      size.width * 0.57, size.height * 0.22,
      size.width * 0.52, size.height * 0.25,
      size.width * 0.52, size.height * 0.25,
    );
    leafPath.close();
    
    canvas.drawPath(leafPath, paint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HatCrownClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Crear forma trapezoidal para la copa del sombrero
    path.moveTo(size.width * 0.15, size.height); // Esquina inferior izquierda
    path.lineTo(size.width * 0.85, size.height); // Esquina inferior derecha
    path.quadraticBezierTo(
      size.width * 0.9, size.height * 0.3, // Control para curva derecha
      size.width * 0.7, size.height * 0.1, // Punto superior derecho
    );
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.0, // Pico del sombrero
      size.width * 0.3, size.height * 0.1, // Punto superior izquierdo
    );
    path.quadraticBezierTo(
      size.width * 0.1, size.height * 0.3, // Control para curva izquierda
      size.width * 0.15, size.height, // Regreso al inicio
    );
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}