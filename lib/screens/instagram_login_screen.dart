import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/instagram_auth_service.dart';

class InstagramLoginScreen extends StatefulWidget {
  const InstagramLoginScreen({super.key});

  @override
  State<InstagramLoginScreen> createState() => _InstagramLoginScreenState();
}

class _InstagramLoginScreenState extends State<InstagramLoginScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://tudominio.com/auth')) {
              _handleRedirect(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(InstagramAuthService.getAuthUrl()));
  }

  void _handleRedirect(String url) async {
    final uri = Uri.parse(url);
    final code = uri.queryParameters['code'];
    
    if (code != null) {
      final token = await InstagramAuthService.exchangeCodeForToken(code);
      if (token != null) {
        final userInfo = await InstagramAuthService.getUserInfo(token);
        if (mounted) {
          Navigator.pop(context, userInfo);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión con Instagram'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}