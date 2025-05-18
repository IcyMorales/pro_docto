import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProduceInfo extends StatelessWidget {
  final Map<String, dynamic>? produceData;

  const ProduceInfo({
    Key? key,
    this.produceData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (produceData == null) {
      return const Center(
        child: Text('No produce information available'),
      );
    }

    return ListView(
      children: [
        ListTile(
          title: Text(produceData!['Description'] ?? ''),
          //subtitle: Text(produceData!['Description'] ?? ''),
        ),
        // Add more widgets to display other produce data
      ],
    );
  }
}
