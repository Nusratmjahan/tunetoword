import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../globals.dart';
import '../services/firebase_service.dart';
import '../services/songletter_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<dynamic> _sentLetters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSentLetters();
  }

  Future<void> _loadSentLetters() async {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final user = firebaseService.currentUser;

    if (user == null) return;

    final result = await SongLetterService.getSentLetters(user.uid);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _sentLetters = result['data'] ?? [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brownDark),
        title: Text('My Letters', style: AppTextStyles.heading2),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sentLetters.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📼', style: TextStyle(fontSize: 80)),
                      const SizedBox(height: 16),
                      Text('No letters yet', style: AppTextStyles.heading2),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first song letter!',
                        style:
                            AppTextStyles.body.copyWith(color: AppColors.sepia),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSentLetters,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _sentLetters.length,
                    itemBuilder: (context, index) {
                      final letter = _sentLetters[index];
                      return _buildLetterCard(letter);
                    },
                  ),
                ),
    );
  }

  Widget _buildLetterCard(dynamic letter) {
    return GestureDetector(
      onTap: () => _showLetterDetails(letter),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.warmWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sepia.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cassette visual
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: CassetteThemes.themes[letter['color_theme']] ??
                    AppColors.amberDeep,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Text('📼', style: TextStyle(fontSize: 50)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    letter['emotion_tag'] ?? 'Song Letter',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color: AppColors.sepia,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    letter['letter']?.substring(
                          0,
                          letter['letter'].length > 40
                              ? 40
                              : letter['letter'].length,
                        ) ??
                        '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Code: ${letter['code']}',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 10,
                      color: AppColors.brownMid,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLetterDetails(dynamic letter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Song Letter Details', style: AppTextStyles.heading2),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Code', letter['code']),
              _detailRow('Emotion', letter['emotion_tag']),
              _detailRow(
                'Created',
                letter['created_at']?.substring(0, 10) ?? 'N/A',
              ),
              const SizedBox(height: 16),
              Text(
                'Letter:',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                letter['letter'] ?? '',
                style: AppTextStyles.body.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'Song:',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                letter['song_link'] ?? '',
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  color: AppColors.amberDeep,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
