import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../globals.dart';
import '../services/firebase_service.dart';
import '../widgets/animated_cassette_widget.dart';
import 'create_song_screen.dart';
import 'library_screen.dart';
import 'login_screen.dart';
import 'memory_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showOpenCassetteDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Open Cassette', style: AppTextStyles.heading2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 8-character code you received:',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                hintText: 'e.g., UHG7L4SE',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = codeController.text.trim().toUpperCase();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemoryScreen(code: code),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amberDeep,
            ),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final user = firebaseService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.amberDeep, AppColors.brownMid],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.music_note,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text('Digital Cassette', style: AppTextStyles.heading2),
          ],
        ),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.brownDark),
              onPressed: () async {
                await firebaseService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Section
              _buildHeroSection(context, user),

              // Divider
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                          height: 1, color: AppColors.sepia.withOpacity(0.2)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(
                        Icons.album,
                        size: 16,
                        color: AppColors.sepia.withOpacity(0.4),
                      ),
                    ),
                    Expanded(
                      child: Container(
                          height: 1, color: AppColors.sepia.withOpacity(0.2)),
                    ),
                  ],
                ),
              ),

              // How It Works Section
              _buildHowItWorksSection(),

              // CTA Section
              _buildCTASection(context),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, dynamic user) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.sepia.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.sepia.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.album, size: 14, color: AppColors.sepia),
                const SizedBox(width: 6),
                Text(
                  'A song says what words can\'t',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.sepia,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Headline
          Text(
            'Send a Song,',
            style: AppTextStyles.heading1.copyWith(fontSize: 36),
          ),
          Text(
            'Seal a Memory',
            style: AppTextStyles.heading1.copyWith(
              fontSize: 36,
              fontStyle: FontStyle.italic,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [AppColors.amberDeep, AppColors.brownMid],
                ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'Like the cassette tapes of old — pick a song, write a letter, '
            'and send it to someone special. They\'ll unlock a nostalgic '
            'experience made just for them.',
            style: AppTextStyles.body.copyWith(
              fontSize: 16,
              height: 1.6,
              color: AppColors.sepia,
            ),
          ),

          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CreateSongScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 22),
                  label: Text('Create', style: AppTextStyles.button),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppColors.amberDeep,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LibraryScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: const BorderSide(color: AppColors.sepia, width: 2),
                  ),
                  child: Text(
                    'My Library',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.brownDark,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Open Cassette Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showOpenCassetteDialog(context),
              icon: const Icon(Icons.lock_open, size: 20),
              label: Text(
                'Open Cassette',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.brownDark,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                side: BorderSide(
                    color: AppColors.amberDeep.withOpacity(0.5), width: 2),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Statistics
          Row(
            children: [
              _buildStatItem('♪', 'Songs Sent'),
              Container(
                width: 1,
                height: 32,
                color: AppColors.sepia.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _buildStatItem('❤️', 'Memories Made'),
              Container(
                width: 1,
                height: 32,
                color: AppColors.sepia.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _buildStatItem('📼', 'Cassettes Created'),
            ],
          ),

          const SizedBox(height: 40),

          // Animated Cassette Player Visual
          AnimatedCassetteWidget(
            colorTheme: 'amber-deep',
            isPlaying: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 10,
              color: AppColors.sepia,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    final features = [
      {
        'icon': Icons.music_note,
        'title': 'Pick a Song',
        'description':
            'Search or paste a YouTube/Spotify link to find the perfect song',
      },
      {
        'icon': Icons.favorite,
        'title': 'Write a Letter',
        'description':
            'Pour your heart out in a personal message with an optional photo',
      },
      {
        'icon': Icons.lock,
        'title': 'Seal with Password',
        'description':
            'Protect your cassette with a secret password only they know',
      },
      {
        'icon': Icons.send,
        'title': 'Share the Link',
        'description':
            'Send a unique link — they unlock, listen, and feel every word',
      },
      {
        'icon': Icons.chat_bubble_outline,
        'title': 'Get a Reply',
        'description':
            'They can reply with their own song, creating a musical conversation',
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Schedule for Special Days',
        'description':
            'Save songs for birthdays, anniversaries, or any day that matters',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.sepia.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.sepia.withOpacity(0.3)),
            ),
            child: Text(
              'HOW IT WORKS',
              style: AppTextStyles.body.copyWith(
                fontSize: 11,
                color: AppColors.sepia,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Making Memories,',
            style: AppTextStyles.heading1.copyWith(fontSize: 28),
          ),
          Text(
            'One Song at a Time',
            style: AppTextStyles.heading1.copyWith(
              fontSize: 28,
              fontStyle: FontStyle.italic,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [AppColors.amberDeep, AppColors.brownMid],
                ).createShader(const Rect.fromLTWH(0, 0, 300, 50)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Creating a musical memory takes less than a minute',
            style: AppTextStyles.body.copyWith(
              color: AppColors.sepia,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Features Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warmWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.sepia.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brownDark.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step number
                    Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.sepia.withOpacity(0.15),
                      ),
                    ),
                    const Spacer(),
                    // Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.amberDeep, AppColors.brownMid],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.amberDeep.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Title
                    Text(
                      feature['title'] as String,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      feature['description'] as String,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        color: AppColors.sepia,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sepia.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.brownDark.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // REC Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sepia.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.sepia.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'REC',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 11,
                      color: AppColors.sepia,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ready to make someone\'s day?',
              style: AppTextStyles.heading1.copyWith(fontSize: 26),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'It only takes a song, a few words, and a little heart.',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 20,
                color: AppColors.sepia,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateSongScreen()),
                  );
                },
                icon: const Icon(Icons.favorite, size: 20),
                label: Text(
                  'Create Your First Cassette',
                  style: AppTextStyles.button,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: AppColors.amberDeep,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.sepia.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.amberDeep, AppColors.brownMid],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.music_note,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Digital Cassette',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Text(
            'Made with ❤️ · Est. 2026',
            style: AppTextStyles.body.copyWith(
              fontSize: 10,
              color: AppColors.sepia.withOpacity(0.6),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
