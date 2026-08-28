import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// MBTI 데이터 모델
class MbtiType {
  final String id;
  final String subtitle;
  final String svgAsset;

  MbtiType({
    required this.id,
    required this.subtitle,
    required this.svgAsset,
  });
}

class MbtiCategory {
  final String title;
  final String subtitle;
  final Color themeColor;
  final List<MbtiType> types;

  MbtiCategory({
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.types,
  });
}

class MbtiPanelScreen extends StatelessWidget {
  MbtiPanelScreen({super.key});

  final List<MbtiCategory> categories = [
    MbtiCategory(
      title: '관리자형 (Sentinels)',
      subtitle: '신뢰할 수 있는 실용주의자',
      themeColor: const Color(0xFF3B82F6), // 파란색 계열
      types: [
        MbtiType(id: 'ISTJ', subtitle: '청렴결백한 논리주의자', svgAsset: 'assets/images/mbti/istj.svg'),
        MbtiType(id: 'ISFJ', subtitle: '용감한 수호자', svgAsset: 'assets/images/mbti/isfj.svg'),
        MbtiType(id: 'ESTJ', subtitle: '엄격한 관리자', svgAsset: 'assets/images/mbti/estj.svg'),
        MbtiType(id: 'ESFJ', subtitle: '사교적인 외교관', svgAsset: 'assets/images/mbti/esfj.svg'),
      ],
    ),
    MbtiCategory(
      title: '외교관형 (Diplomats)',
      subtitle: '공감 능력이 뛰어난 이상주의자',
      themeColor: const Color(0xFFEF4444), // 붉은색 계열
      types: [
        MbtiType(id: 'INFJ', subtitle: '선의의 옹호자', svgAsset: 'assets/images/mbti/infj.svg'),
        MbtiType(id: 'INFP', subtitle: '열정적인 중재자', svgAsset: 'assets/images/mbti/infp.svg'),
        MbtiType(id: 'ENFJ', subtitle: '정의로운 사회운동가', svgAsset: 'assets/images/mbti/enfj.svg'),
        MbtiType(id: 'ENFP', subtitle: '재기발랄한 활동가', svgAsset: 'assets/images/mbti/enfp.svg'),
      ],
    ),
    MbtiCategory(
      title: '분석형 (Analysts)',
      subtitle: '합리적이고 독립적인 지식인',
      themeColor: const Color(0xFFA855F7), // 보라색 계열
      types: [
        MbtiType(id: 'INTJ', subtitle: '용의주도한 전략가', svgAsset: 'assets/images/mbti/intj.svg'),
        MbtiType(id: 'INTP', subtitle: '논리적인 사색가', svgAsset: 'assets/images/mbti/intp.svg'),
        MbtiType(id: 'ENTJ', subtitle: '대담한 통솔자', svgAsset: 'assets/images/mbti/entj.svg'),
        MbtiType(id: 'ENTP', subtitle: '뜨거운 논쟁을 즐기는 변론가', svgAsset: 'assets/images/mbti/entp.svg'),
      ],
    ),
    MbtiCategory(
      title: '탐험가형 (Explorers)',
      subtitle: '자유롭고 매력적인 예술가',
      themeColor: const Color(0xFFEAB308), // 노란색 계열
      types: [
        MbtiType(id: 'ISTP', subtitle: '만능 재주꾼', svgAsset: 'assets/images/mbti/istp.svg'),
        MbtiType(id: 'ISFP', subtitle: '호기심 많은 예술가', svgAsset: 'assets/images/mbti/isfp.svg'),
        MbtiType(id: 'ESTP', subtitle: '모험을 즐기는 사업가', svgAsset: 'assets/images/mbti/estp.svg'),
        MbtiType(id: 'ESFP', subtitle: '자유로운 영혼의 연예인', svgAsset: 'assets/images/mbti/esfp.svg'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // 다크 배경
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          'MBTI 선택',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryPanel(category);
        },
      ),
    );
  }

  Widget _buildCategoryPanel(MbtiCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // 배경과 동일하게 하거나 살짝 띄우기
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: category.themeColor.withOpacity(0.5), // 테두리 색상
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 제목
          Text(
            category.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: category.themeColor,
            ),
          ),
          const SizedBox(height: 6),
          // 카테고리 부제목
          Text(
            category.subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          // MBTI 리스트
          ...category.types.map((mbti) => _buildMbtiItem(mbti)).toList(),
        ],
      ),
    );
  }

  Widget _buildMbtiItem(MbtiType mbti) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C34), // 항목 다크 배경
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          // 둥근 흰색 배경 안의 SVG 이미지
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: SvgPicture.asset(
              mbti.svgAsset,
              fit: BoxFit.contain,
              placeholderBuilder: (BuildContext context) => const CircularProgressIndicator(),
            ),
          ),
          const SizedBox(width: 16),
          // 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mbti.id,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mbti.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // [보기] 버튼
          OutlinedButton(
            onPressed: () {
              // 임시 보류 - 추후 지시에 따라 라우팅
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5), // 보라색 테두리
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
            child: const Text(
              '보기',
              style: TextStyle(
                color: Color(0xFF8B5CF6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
