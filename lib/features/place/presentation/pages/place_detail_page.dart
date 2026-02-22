import 'package:flutter/material.dart';

class PlaceDetailPage extends StatelessWidget {
  const PlaceDetailPage({required this.placeId, super.key});

  final String placeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del lugar')),
      body: Center(
        child: Text(
          'Lugar: $placeId',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
