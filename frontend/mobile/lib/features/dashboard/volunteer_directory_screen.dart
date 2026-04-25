import 'package:flutter/material.dart';

class VolunteerDirectoryScreen extends StatelessWidget {
  const VolunteerDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Volunteer Directory', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...List.generate(
              10,
              (index) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text('Volunteer ${index + 1}'),
                subtitle: const Text('Last verified task: Food Distribution'),
                trailing: const Text('Impact 80+'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
