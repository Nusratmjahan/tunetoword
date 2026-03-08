import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../globals.dart';
import '../services/firebase_service.dart';
import '../services/songletter_service.dart';

class CreateSongScreen extends StatefulWidget {
  const CreateSongScreen({super.key});

  @override
  State<CreateSongScreen> createState() => _CreateSongScreenState();
}

class _CreateSongScreenState extends State<CreateSongScreen> {
  int _currentStep = 1;
  final _songLinkController = TextEditingController();
  final _letterController = TextEditingController();
  final _passwordController = TextEditingController();
  final _receiverEmailController = TextEditingController();

  String _selectedColorTheme = 'amber-deep';
  String _selectedEmotion = 'Nostalgia';
  DateTime? _scheduledDate;
  bool _isLoading = false;
  bool _showPassword = false;
  File? _selectedPhoto;
  final ImagePicker _picker = ImagePicker();

  String? _generatedCode;

  Future<void> _createSongLetter() async {
    setState(() => _isLoading = true);

    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final user = firebaseService.currentUser;

    if (user == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    // Upload photo first if selected
    String? photoUrl;
    if (_selectedPhoto != null) {
      final uploadResult = await SongLetterService.uploadPhoto(
        photoFile: _selectedPhoto!,
        userId: user.uid,
      );

      if (uploadResult['success']) {
        photoUrl = uploadResult['photo_url'];
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(uploadResult['error'] ?? 'Failed to upload photo')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
    }

    final result = await SongLetterService.createSongLetter(
      senderId: user.uid,
      songLink: _songLinkController.text.trim(),
      letter: _letterController.text.trim(),
      password: _passwordController.text,
      receiverEmail: _receiverEmailController.text.trim().isEmpty
          ? null
          : _receiverEmailController.text.trim(),
      colorTheme: _selectedColorTheme,
      emotionTag: _selectedEmotion.toLowerCase(),
      photoUrl: photoUrl,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _generatedCode = result['data']['code'];
        _currentStep = 5;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to create song letter'),
        ),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedPhoto = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick photo: $e')),
        );
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedPhoto = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.brownDark),
        title: Text('Create Cassette', style: AppTextStyles.heading2),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar
              if (_currentStep < 5) _buildProgressBar(),
              const SizedBox(height: 32),

              // Step Content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(4, (index) {
        final isActive = index < _currentStep;
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: isActive
                  ? const LinearGradient(
                      colors: [AppColors.amberDeep, AppColors.brownMid],
                    )
                  : null,
              color: isActive ? null : AppColors.sepia.withOpacity(0.2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      case 5:
        return _buildStep5();
      default:
        return _buildStep1();
    }
  }

  // Step 1: Pick a Song
  Widget _buildStep1() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pick a Song',
          style: AppTextStyles.heading1.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          'Paste a YouTube or Spotify link',
          style: AppTextStyles.body.copyWith(color: AppColors.sepia),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _songLinkController,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'https://youtube.com/watch?v=... or spotify link',
            prefixIcon: const Icon(Icons.link, color: AppColors.sepia),
            filled: true,
            fillColor: AppColors.warmWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.sepia.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.sepia.withOpacity(0.6)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Song search coming soon — paste a link for now',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.sepia.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _songLinkController.text.isEmpty ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: AppColors.amberDeep,
          ),
          child: Text(
            'Next: Write Your Letter',
            style: AppTextStyles.button,
          ),
        ),
      ],
    );
  }

  // Step 2: Write Letter
  Widget _buildStep2() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          onPressed: _previousStep,
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Back'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.sepia,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Write Your Letter',
          style: AppTextStyles.heading1.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          'Say what the song can\'t',
          style: AppTextStyles.body.copyWith(color: AppColors.sepia),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _letterController,
          onChanged: (value) => setState(() {}),
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Dear friend, this song reminds me of...',
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
        const SizedBox(height: 24),
        Text(
          'Add a photo (optional)',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _selectedPhoto != null
            ? Stack(
                children: [
                  // Photo preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _selectedPhoto!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Remove button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: _removePhoto,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : InkWell(
                onTap: _pickPhoto,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  decoration: BoxDecoration(
                    color: AppColors.warmWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.sepia.withOpacity(0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: 40,
                        color: AppColors.sepia.withOpacity(0.6),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click to upload a cover photo',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.sepia.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _letterController.text.isEmpty ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: AppColors.amberDeep,
          ),
          child: Text(
            'Next: Add Emotion',
            style: AppTextStyles.button,
          ),
        ),
      ],
    );
  }

  // Step 3: Emotion & Schedule
  Widget _buildStep3() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          onPressed: _previousStep,
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Back'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.sepia,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Set the Mood',
          style: AppTextStyles.heading1.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          'Pick an emotion tag (optional)',
          style: AppTextStyles.body.copyWith(color: AppColors.sepia),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EmotionTags.tags.map((emotion) {
            final isSelected = _selectedEmotion == emotion;
            return InkWell(
              onTap: () => setState(() => _selectedEmotion = emotion),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.amberDeep : AppColors.warmWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.amberDeep
                        : AppColors.sepia.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  emotion,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.brownDark,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 18,
              color: AppColors.amberDeep,
            ),
            const SizedBox(width: 8),
            Text(
              'Schedule for a special day (optional)',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.amberDeep,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() => _scheduledDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warmWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.sepia.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.event, color: AppColors.sepia),
                const SizedBox(width: 12),
                Text(
                  _scheduledDate != null
                      ? '${_scheduledDate!.month}/${_scheduledDate!.day}/${_scheduledDate!.year}'
                      : 'Tap to pick a date',
                  style: AppTextStyles.body.copyWith(
                    color: _scheduledDate != null
                        ? AppColors.brownDark
                        : AppColors.sepia,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: AppColors.amberDeep,
          ),
          child: Text(
            'Next: Set Password',
            style: AppTextStyles.button,
          ),
        ),
      ],
    );
  }

  // Step 4: Password
  Widget _buildStep4() {
    return Column(
      key: const ValueKey(4),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          onPressed: _previousStep,
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Back'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.sepia,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Seal Your Cassette',
          style: AppTextStyles.heading1.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a password only they would know',
          style: AppTextStyles.body.copyWith(color: AppColors.sepia),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _passwordController,
          onChanged: (value) => setState(() {}),
          obscureText: !_showPassword,
          decoration: InputDecoration(
            hintText: 'e.g., moonlight, our-song, 2024summer',
            filled: true,
            fillColor: AppColors.warmWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.sepia,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Cassette Color Theme',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: CassetteThemes.themes.entries.map((entry) {
            final isSelected = _selectedColorTheme == entry.key;
            return InkWell(
              onTap: () => setState(() => _selectedColorTheme = entry.key),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: entry.value,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.brownDark : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warmWhite.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.sepia.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preview',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.sepia,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.music_note,
                      color: AppColors.amberDeep, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your cassette will be sealed with this password',
                      style: AppTextStyles.body.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _passwordController.text.isEmpty || _isLoading
              ? null
              : _createSongLetter,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: AppColors.amberDeep,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Generate Cassette Link',
                      style: AppTextStyles.button,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // Step 5: Success
  Widget _buildStep5() {
    return Column(
      key: const ValueKey(5),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.amberDeep, AppColors.brownMid],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.music_note,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Your Cassette is Ready!',
          style: AppTextStyles.heading1.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Share this link with someone special',
          style: AppTextStyles.body.copyWith(color: AppColors.sepia),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.sepia.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Code',
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  color: AppColors.sepia,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _generatedCode ?? '',
                style: AppTextStyles.body.copyWith(
                  fontFamily: 'Courier',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.sepia.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  color: AppColors.sepia,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _passwordController.text,
                style: AppTextStyles.body.copyWith(
                  fontFamily: 'Courier',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            Clipboard.setData(
              ClipboardData(
                text: '🎵 You\'ve received a CassetteNote!\n\n'
                    '1. Open CassetteNote app\n'
                    '2. Tap "Open Cassette"\n'
                    '3. Enter code: $_generatedCode\n'
                    '4. Enter password: ${_passwordController.text}\n\n'
                    'Enjoy the music! 📼',
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard!')),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: AppColors.amberDeep,
          ),
          child: Text(
            'Copy Share Message',
            style: AppTextStyles.button,
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
            'Back to Home',
            style: AppTextStyles.button.copyWith(color: AppColors.brownDark),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _songLinkController.dispose();
    _letterController.dispose();
    _passwordController.dispose();
    _receiverEmailController.dispose();
    super.dispose();
  }
}
