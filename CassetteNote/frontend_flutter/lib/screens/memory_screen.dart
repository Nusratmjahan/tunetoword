import 'package:flutter/material.dart';
import '../globals.dart';
import '../services/songletter_service.dart';
import '../widgets/animated_cassette_widget.dart';
import '../widgets/retro_widgets.dart';
import '../widgets/song_embed_widget.dart';

enum MemoryStage { password, cassette, letter, reply }

class MemoryScreen extends StatefulWidget {
  final String code;

  const MemoryScreen({super.key, required this.code});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  MemoryStage _currentStage = MemoryStage.password;
  final _passwordController = TextEditingController();
  final _replyController = TextEditingController();
  final _replySongController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _songLetter;
  String? _error;

  Future<void> _unlock() async {
    if (_passwordController.text.isEmpty) {
      setState(() => _error = 'Please enter password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await SongLetterService.getSongLetterByCode(
      code: widget.code,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      setState(() {
        _songLetter = result['data'];
        _currentStage = MemoryStage.cassette;
      });
    } else {
      setState(() {
        _error = result['error'] ?? 'Invalid password';
      });
    }
  }

  void _nextStage() {
    setState(() {
      switch (_currentStage) {
        case MemoryStage.password:
          _currentStage = MemoryStage.cassette;
          break;
        case MemoryStage.cassette:
          _currentStage = MemoryStage.letter;
          break;
        case MemoryStage.letter:
          _currentStage = MemoryStage.reply;
          break;
        case MemoryStage.reply:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _buildStageContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_currentStage) {
      case MemoryStage.password:
        return _buildPasswordStage();
      case MemoryStage.cassette:
        return _buildCassetteStage();
      case MemoryStage.letter:
        return _buildLetterStage();
      case MemoryStage.reply:
        return _buildReplyStage();
    }
  }

  // Stage 1: Password Gate
  Widget _buildPasswordStage() {
    return Column(
      key: const ValueKey('password'),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.amberDeep, AppColors.brownMid],
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: AppColors.amberDeep.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_outline,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'You\'ve received a cassette',
          style: AppTextStyles.heading1.copyWith(fontSize: 26),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the password to unlock it',
          style: AppTextStyles.body.copyWith(color: AppColors.sepia),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _passwordController,
          obscureText: true,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Enter password...',
            filled: true,
            fillColor: AppColors.warmWhite,
            errorText: _error,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.sepia.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.sepia.withOpacity(0.3),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          style: AppTextStyles.body.copyWith(fontSize: 16),
          onSubmitted: (_) => _unlock(),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _unlock,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Icon(Icons.lock_open, size: 20),
          label: Text(
            _isLoading ? 'Unlocking...' : 'Unlock Cassette',
            style: AppTextStyles.button,
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: AppColors.amberDeep,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Code: ${widget.code}',
          style: AppTextStyles.body.copyWith(
            fontSize: 12,
            color: AppColors.sepia.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Stage 2: Cassette Stage
  Widget _buildCassetteStage() {
    return Column(
      key: const ValueKey('cassette'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Now playing...',
          style: AppTextStyles.body.copyWith(
            color: AppColors.sepia,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Animated Cassette Widget
        AnimatedCassetteWidget(
          colorTheme: _songLetter?['color_theme'] ?? 'amber-deep',
          photoUrl: _songLetter?['photo_url'],
          isPlaying: true,
        ),

        const SizedBox(height: 32),

        // Emotion tag
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.warmWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.sepia.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🌅',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  _songLetter?['emotion_tag'] ?? 'Nostalgia',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brownDark,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Song embed if available
        if (_songLetter?['song_link'] != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warmWhite.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.sepia.withOpacity(0.2),
              ),
            ),
            child: SongEmbedWidget(songUrl: _songLetter!['song_link']),
          ),

        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: _nextStage,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: AppColors.amberDeep,
          ),
          child: Text(
            'Read the Letter',
            style: AppTextStyles.button,
          ),
        ),
      ],
    );
  }

  // Stage 3: Letter Stage
  Widget _buildLetterStage() {
    return Column(
      key: const ValueKey('letter'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.music_note,
              size: 18,
              color: AppColors.sepia,
            ),
            const SizedBox(width: 8),
            Text(
              'Music is still playing...',
              style: AppTextStyles.body.copyWith(
                color: AppColors.sepia,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Letter Display with Vintage Paper Effect
        VintagePaperWidget(
          text: _songLetter?['letter'] ?? '',
        ),

        const SizedBox(height: 16),

        // Sender info in retro container
        RetroContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundColor: AppColors.warmWhite.withOpacity(0.5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mail_outline,
                size: 16,
                color: AppColors.sepia,
              ),
              const SizedBox(width: 8),
              Text(
                'From: Someone who cares',
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brownDark,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        ElevatedButton.icon(
          onPressed: _nextStage,
          icon: const Icon(Icons.chat_bubble_outline, size: 20),
          label: Text(
            'Reply to this Cassette',
            style: AppTextStyles.button,
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: AppColors.amberDeep,
          ),
        ),
      ],
    );
  }

  // Stage 4: Reply Stage
  Widget _buildReplyStage() {
    return Column(
      key: const ValueKey('reply'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Send a Reply',
          style: AppTextStyles.heading1.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          'Reply with a message, or even another song',
          style: AppTextStyles.body.copyWith(
            color: AppColors.sepia,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 24),

        // Reply text
        TextField(
          controller: _replyController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Write your reply...',
            filled: true,
            fillColor: AppColors.warmWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(
            fontFamily: 'Caveat',
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 16),

        // Optional song link
        TextField(
          controller: _replySongController,
          decoration: InputDecoration(
            hintText: 'Paste a song link (optional)',
            prefixIcon: const Icon(
              Icons.music_note,
              color: AppColors.sepia,
            ),
            filled: true,
            fillColor: AppColors.warmWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 24),

        ElevatedButton.icon(
          onPressed: _replyController.text.isEmpty
              ? null
              : () {
                  // TODO: Implement reply submission
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reply feature coming soon!'),
                    ),
                  );
                },
          icon: const Icon(Icons.send, size: 20),
          label: Text(
            'Send Reply',
            style: AppTextStyles.button,
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: AppColors.amberDeep,
          ),
        ),

        const SizedBox(height: 12),

        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            side: const BorderSide(color: AppColors.sepia),
          ),
          child: Text(
            'Close',
            style: AppTextStyles.button.copyWith(
              color: AppColors.brownDark,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _replyController.dispose();
    _replySongController.dispose();
    super.dispose();
  }
}
