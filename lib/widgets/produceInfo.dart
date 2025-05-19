import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class ProduceInfo extends StatelessWidget {
  final Map<String, dynamic>? produceData;
  final double? produceAccuracy;
  final String? produceQuality;

  const ProduceInfo({
    Key? key,
    this.produceData,
    this.produceAccuracy,
    this.produceQuality,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> _getNutrients() async {
    if (produceData == null) return [];

    try {
      final nutrientsRef = FirebaseFirestore.instance
          .collection('Nutrition')
          .where('Produce_Name', isEqualTo: produceData!['Name']);

      final querySnapshot = await nutrientsRef.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching nutrients: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _getRecommendation() async {
    if (produceData == null) return null;

    try {
      final recommendationsRef = FirebaseFirestore.instance
          .collection('Recommendation')
          .where('Produce_Name', isEqualTo: produceData!['Name'])
          .where('Class', isEqualTo: produceQuality);

      final querySnapshot = await recommendationsRef.get();

      if (querySnapshot.docs.isEmpty) return null;

      // Randomly select one recommendation if multiple exist
      final random = Random();
      final randomIndex = random.nextInt(querySnapshot.docs.length);
      return querySnapshot.docs[randomIndex].data();
    } catch (e) {
      print('Error fetching recommendation: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (produceData == null) {
      return const Center(
        child: Text('No produce information available'),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
      children: [
        ListTile(
          title: const Text(
            'Identification Prediction:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            '${(produceAccuracy ?? 0.0 * 100).toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        ListTile(
          title: const Text(
            'Freshness:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            produceQuality ?? 'Unknown',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        ListTile(
          title: const Text(
            'Description:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            produceData!['Description'] ?? '',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _getNutrients(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const ListTile(
                title: Text(
                  'Nutrients:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text('No nutrition information available'),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Nutrients:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: snapshot.data!
                      .map((nutrient) => Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFDB7307).withOpacity(0.3),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nutrient['Name'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Text(
                                            'DV: ',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            '${nutrient['DV'] ?? 'N/A'}%',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 2,
                                      height: 12,
                                      color: const Color(
                                          0xFFDB7307), // Orange separator
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Value: ',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            '${nutrient['Value'] ?? '0'} mg', // Changed to use fixed 'mg' unit
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            );
          },
        ),
        FutureBuilder<Map<String, dynamic>?>(
          future: _getRecommendation(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData) {
              return const ListTile(
                title: Text(
                  'Recommendation:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text('No recommendation available'),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Recommendation:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFDB7307).withOpacity(0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    snapshot.data!['Content'] ?? '',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.justify, // Add this line
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
