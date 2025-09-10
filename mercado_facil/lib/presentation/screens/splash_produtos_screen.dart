import 'package:flutter/material.dart';

class SplashProdutosScreen extends StatefulWidget {
  const SplashProdutosScreen({super.key});

  @override
  State<SplashProdutosScreen> createState() => _SplashProdutosScreenState();
}

class _SplashProdutosScreenState extends State<SplashProdutosScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/produtos');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 80, color: colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Indo para produtos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}