import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProduceInfo extends StatelessWidget {
  final String? detected_produce;

  const ProduceInfo({
    super.key,
    required this.detected_produce,
  });

  @override
  Widget build(BuildContext context) {
    if (detected_produce == null) {
      return const Center(
        child: Text('No produce detected yet'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Produce')
          .where('Name', isEqualTo: detected_produce)
          .limit(1)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No data found for $detected_produce'),
          );
        }

        final produceData =
            snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final produceId = snapshot.data!.docs.first.id;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Nutrition')
              .where('Produce_ID', isEqualTo: produceId)
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> nutritionSnapshot) {
            if (nutritionSnapshot.hasError) {
              return const Text('Error loading nutrition data');
            }

            if (nutritionSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    produceData['Name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    produceData['Description'] ?? 'No description available',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Text(
                        'Price: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₱${produceData['Price'] ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFD67A0F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: nutritionSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final nutrientData = nutritionSnapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(
                          nutrientData['Name'] ?? 'Unknown Nutrient',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              'Value: ${nutrientData['Value']} ',
                              style: const TextStyle(
                                color: Color(0xFFD67A0F),
                              ),
                            ),
                            Text(
                              'DV: ${nutrientData['DV']}%',
                              style: const TextStyle(
                                color: Color(0xFFD67A0F),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
