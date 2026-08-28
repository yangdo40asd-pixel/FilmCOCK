import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 변경된 프로필 정보 저장 로직
              Navigator.of(context).pop(); // 저장 후 이전 화면으로 돌아가기
            },
            child: const Text(
              '저장',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : null,
                child: _imageFile == null
                    ? const Icon(Icons.person, size: 70, color: Colors.white)
                    : null,
              ),
              TextButton(
                onPressed: () {
                  // 이미지 선택 기능 호출
                  _pickImage();
                },
                child: const Text('이미지 변경'),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                label: '닉네임',
                initialValue: '신이난_강동원_991211', // 현재 닉네임 (임시)
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: '자기 소개',
                initialValue: '안녕하세요.', // 현재 자기소개 (임시)
                maxLines: 4, // 여러 줄 입력 가능
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
