import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../globals.dart';
import '../services/firebase_service.dart';
import '../services/songletter_service.dart';

class ReplyForm extends StatefulWidget {
  final String songLetterId;

  const ReplyForm({super.key, required this.songLetterId});

  @override
  State<ReplyForm> createState() => _ReplyFormState();
}

class _ReplyFormState extends State<ReplyForm> {
  final _messageController = TextEditingController();
  final _songLinkController = TextEditingController();
  bool _isLoading = false;
  bool _showForm = false;

  Future<void> _sendReply() async {
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please write a message')));
      return;
    }

    setState(() => _isLoading = true);

    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final user = firebaseService.currentUser;

    final result = await SongLetterService.createReply(
      songLetterId: widget.songLetterId,
      senderId: user?.uid ?? 'anonymous',
      message: _messageController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply sent successfully! 🎵')),
      );

      setState(() {
        _messageController.clear();
        _songLinkController.clear();
        _showForm = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Failed to send reply')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showForm) {
      return ElevatedButton.icon(
        onPressed: () => setState(() => _showForm = true),
        icon: const Icon(Icons.reply),
        label: Text('Reply with a Song', style: AppTextStyles.button),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.sepia.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Send a Reply',
            style: AppTextStyles.heading2.copyWith(fontSize: 20),
          ),

          const SizedBox(height: 16),

          // Message
          TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write your reply...',
              filled: true,
              fillColor: AppColors.cream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Optional song link
          TextField(
            controller: _songLinkController,
            decoration: InputDecoration(
              hintText: 'Add a song link (optional)',
              filled: true,
              fillColor: AppColors.cream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _showForm = false;
                    _messageController.clear();
                    _songLinkController.clear();
                  }),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendReply,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Send'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _songLinkController.dispose();
    super.dispose();
  }
}
