import 'package:flutter/material.dart';

class VolunteerProfileScreen extends StatelessWidget {
  const VolunteerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        CircleAvatar(radius: 36, child: Icon(Icons.person, size: 32)),
        SizedBox(height: 12),
        Center(
          child: Text(
            'Volunteer Profile',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(height: 18),
        Card(
          child: ListTile(
            leading: Icon(Icons.insights_outlined),
            title: Text('Impact Score'),
            subtitle: Text('82 / 100'),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.task_alt),
            title: Text('Completed Tasks'),
            subtitle: Text('27 tasks'),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.workspace_premium_outlined),
            title: Text('Badges'),
            subtitle: Text('Community Builder, Eco Warrior'),
          ),
        ),
      ],
    );
  }
}
