import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:filmcock_app/data/models/mbti_info.dart';
import 'package:filmcock_app/presentation/screens/onboarding/mbti_detail_screen.dart';

class MbtiCategory {
  final String title;
  final String subtitle;
  final Color themeColor;
  final List<String> mbtiIds;

  const MbtiCategory({
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.mbtiIds,
  });
}

class MbtiPanelScreen extends StatefulWidget {
  const MbtiPanelScreen({super.key});

  @override
  State<MbtiPanelScreen> createState() => _MbtiPanelScreenState();
}

class _MbtiPanelScreenState extends State<MbtiPanelScreen> {
  // 16개 전체 보기 확장 여부
  bool _isExpanded = false;

  final List<MbtiCategory> categories = const [
    MbtiCategory(
      title: '관리자형 (Sentinels)',
      subtitle: '신뢰할 수 있는 실용주의자',
      themeColor: Color(0xFFE25C5C),
      mbtiIds: ['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'],
    ),
    MbtiCategory(
      title: '외교형 (Diplomats)',
      subtitle: '공감 능력이 뛰어난 이상주의자',
      themeColor: Color(0xFF10B981),
      mbtiIds: ['INFJ', 'INFP', 'ENFJ', 'ENFP'],
    ),
    MbtiCategory(
      title: '분석가형 (Analysts)',
      subtitle: '합리적이고 전략적인 사색가',
      themeColor: Color(0xFFA855F7),
      mbtiIds: ['INTJ', 'INTP', 'ENTJ', 'ENTP'],
    ),
    MbtiCategory(
      title: '탐험가형 (Explorers)',
      subtitle: '즉흥적이고 에너지가 넘치는 모험가',
      themeColor: Color(0xFFEAB308),
      mbtiIds: ['ISTP', 'ISFP', 'ESTP', 'ESFP'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 확장되지 않은 경우 첫 번째 카테고리만 노출
    final displayedCategories = _isExpanded ? categories : [categories[0]];

    return Scaffold(
      backgroundColor: const Color(0xFF16161A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161A),
        elevation: 0,
        title: const Text(
          'MBTI 선택',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            ...displayedCategories.map((category) => _buildCategoryPanel(context, category)),
            const SizedBox(height: 8.0),
            // '16개 성격 유형 모두 보기' 토글 버튼
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1F28),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: const Color(0xFF6B4EE6),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF8B5CF6),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isExpanded ? '성격 유형 접기' : '16개 성격 유형 모두 보기',
                        style: const TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPanel(BuildContext context, MbtiCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: category.themeColor.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 타이틀
          Text(
            category.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: category.themeColor,
            ),
          ),
          const SizedBox(height: 6),
          // 서브타이틀
          Text(
            category.subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFA0A0AB),
            ),
          ),
          const SizedBox(height: 18),
          // 각 MBTI 항목 목록
          ...category.mbtiIds.map((id) {
            final info = getMbtiInfoById(id);
            if (info == null) return const SizedBox.shrink();
            return _buildMbtiItem(context, info);
          }),
        ],
      ),
    );
  }

  Widget _buildMbtiItem(BuildContext context, MbtiInfo mbti) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF26262E),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        children: [
          // 캐릭터 일러스트 박스
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: SvgPicture.asset(
              mbti.svgAsset,
              fit: BoxFit.contain,
              placeholderBuilder: (_) => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // 이름 및 설명
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mbti.id,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mbti.title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFA0A0AB),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 우측 [보기] 버튼
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MbtiDetailScreen(mbtiInfo: mbti),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF6B4EE6), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              backgroundColor: const Color(0xFF1E1E28),
            ),
            child: const Text(
              '보기',
              style: TextStyle(
                color: Color(0xFF8B5CF6),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
