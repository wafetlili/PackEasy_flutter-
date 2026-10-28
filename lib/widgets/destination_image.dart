import 'package:flutter/material.dart';
import '../models/destination.dart';

class DestinationImage extends StatelessWidget {
  final Destination destination;
  final double? height;

  const DestinationImage({super.key, required this.destination, this.height});

  Widget _placeholder({Widget? child}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF26C6DA), Color(0xFF5C6BC0)],
        ),
      ),
      child: Center(
        child: child ?? Text(destination.flag, style: const TextStyle(fontSize: 60)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      destination.image,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : _placeholder(child: const CircularProgressIndicator(color: Colors.white)),
      errorBuilder: (context, error, stack) => _placeholder(),
    );
  }
}