import 'package:flutter/material.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:unityhub_mobile/core/config/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class ClaimRewardsButton extends StatefulWidget {
  final String taskId;
  
  const ClaimRewardsButton({super.key, required this.taskId});

  @override
  State<ClaimRewardsButton> createState() => _ClaimRewardsButtonState();
}

class _ClaimRewardsButtonState extends State<ClaimRewardsButton> {
  bool _isMinting = false;
  String? _txHash;
  bool _error = false;

  Future<void> _claimReward() async {
    setState(() {
      _isMinting = true;
      _error = false;
    });

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/mint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _txHash = "0x123...abc"; // In a real app parse from response
        });
      } else {
        setState(() => _error = true);
      }
    } catch (_) {
      setState(() => _error = true);
    } finally {
      setState(() => _isMinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_txHash != null) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.open_in_new),
        label: const Text('Success! View on Explorer'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
        onPressed: () async {
          final url = Uri.parse('https://amoy.polygonscan.com/tx/$_txHash');
          if (await canLaunchUrl(url)) await launchUrl(url);
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: _isMinting ? null : _claimReward,
          child: _isMinting
              ? const Text('Minting on Polygon...')
              : const Text('Claim Reward'),
        ),
        if (_isMinting) const SizedBox(height: 8),
        if (_isMinting) const LinearProgressIndicator(),
        if (_error)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Failed to claim reward.', style: TextStyle(color: AppColors.warning)),
          ),
      ],
    );
  }
}
