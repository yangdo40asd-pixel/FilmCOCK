import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:filmcock_app/data/repositories/user_settings_repository.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final UserSettingsRepository _settingsRepository =
      const UserSettingsRepository();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  String? _savedImagePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final profile = await _settingsRepository.loadProfile();
    final nickname = profile.nickname;
    final bio = profile.bio;
    final imagePath = profile.imagePath;
    final hasSavedImage =
        imagePath != null &&
        imagePath.isNotEmpty &&
        File(imagePath).existsSync();
    if (imagePath != null && !hasSavedImage) {
      await _settingsRepository.saveProfile(
        UserProfileData(nickname: nickname, bio: bio),
      );
    }

    if (!mounted) return;
    setState(() {
      _nicknameController.text = nickname;
      _bioController.text = bio;
      _savedImagePath = hasSavedImage ? imagePath : null;
      if (hasSavedImage) {
        _imageFile = File(imagePath);
      }
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final documents = await getApplicationDocumentsDirectory();
        final extension = pickedFile.path.contains('.')
            ? pickedFile.path.split('.').last
            : 'jpg';
        final savedFile = await File(pickedFile.path).copy(
          '${documents.path}${Platform.pathSeparator}profile_${DateTime.now().millisecondsSinceEpoch}.$extension',
        );
        if (!mounted) return;
        setState(() {
          _imageFile = savedFile;
        });
      }
    } on PlatformException catch (error) {
      if (mounted) {
        final message = error.code == 'photo_access_denied'
            ? '사진 접근 권한이 없습니다. 기기 설정에서 권한을 허용해주세요.'
            : '사진 앱에서 이미지를 불러오지 못했습니다. 다시 선택해주세요.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } on FileSystemException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('선택한 이미지를 앱 저장 공간에 복사하지 못했습니다.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 불러오지 못했습니다. 다른 이미지를 선택해주세요.')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final nickname = _nicknameController.text.trim();
    final bio = _bioController.text.trim();

    if (nickname.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('닉네임을 입력해주세요.')));
      return;
    }

    await _settingsRepository.saveProfile(
      UserProfileData(
        nickname: nickname,
        bio: bio,
        imagePath: _imageFile?.path ?? _savedImagePath,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필이 저장되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF141414),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFA88BFA)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: '뒤로 가기',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '프로필 수정',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              '저장',
              style: TextStyle(
                color: Color(0xFFA88BFA),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: ClipOval(
                    child: _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          )
                        : (_savedImagePath != null &&
                              _savedImagePath!.isNotEmpty &&
                              File(_savedImagePath!).existsSync())
                        ? Image.file(
                            File(_savedImagePath!),
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/popcorn_logo.png',
                            width: 110,
                            height: 110,
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, stack) => const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Image Change Button
              TextButton(
                onPressed: _pickImage,
                child: const Text(
                  '이미지 변경',
                  style: TextStyle(
                    color: Color(0xFFA88BFA),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Nickname Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '닉네임',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nicknameController,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2C2C2E),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Bio Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '자기 소개',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2C2C2E),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
