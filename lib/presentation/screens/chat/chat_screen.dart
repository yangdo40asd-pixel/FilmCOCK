import 'package:flutter/material.dart';
import 'package:filmcock_app/data/chatbot/chatbot_database.dart';
import 'package:filmcock_app/data/services/chatbot_service.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotService _chatbotService = ChatbotService();

  final List<ChatMessage> _messages = [];
  bool _isProcessing = false;
  String _selectedCategory = '전체';

  final List<String> _categories = ['전체', '기분', '상황', '테마', 'MBTI'];

  @override
  void initState() {
    super.initState();
    // 챗봇 첫 인사 메시지
    _messages.add(
      ChatMessage(
        text: '안녕하세요. 필름콕 AI 영화 도슨트입니다. 기분, 상황, 선호하는 장르를 말씀해주시면 딱 맞는 맞춤 영화를 안내해 드립니다.',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleUserMessage(String userText) async {
    final trimmed = userText.trim();
    if (trimmed.isEmpty || _isProcessing) return;

    _inputController.clear();
    setState(() {
      _messages.add(ChatMessage(text: trimmed, isUser: true));
      _isProcessing = true;
    });
    _scrollToBottom();

    // 챗봇 알고리즘 처리
    final response = await _chatbotService.processInput(trimmed);

    if (mounted) {
      setState(() {
        _messages.add(response);
        _isProcessing = false;
      });
      _scrollToBottom();
    }
  }

  void _resetChat() {
    setState(() {
      _chatbotService.reset();
      _messages.clear();
      _messages.add(
        ChatMessage(
          text: '대화가 초기화되었습니다. 어떤 영화를 찾고 계신가요? 상단 추천 질문을 누르거나 직접 물어보세요.',
          isUser: false,
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('대화가 새로 시작되었습니다.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  List<ChatbotPrompt> get _filteredPrompts {
    if (_selectedCategory == '전체') {
      return ChatbotDatabase.promptChips;
    }
    return ChatbotDatabase.promptChips
        .where((p) => p.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF141418) : const Color(0xFFF7F7FA);
    final appBarColor = isDark ? const Color(0xFF1E1E26) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF191919);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '필름콕 AI 도슨트',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            tooltip: '대화 초기화',
            onPressed: _resetChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. 상단 추천 질문 칩 바 (카테고리 탭 + 가로 스크롤 칩)
          _buildPromptShelf(isDark),

          const Divider(height: 1, color: Colors.white12),

          // 2. 채팅 메시지 리스트
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              itemCount: _messages.length + (_isProcessing ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isProcessing) {
                  return _buildTypingIndicator(isDark);
                }
                final message = _messages[index];
                return _buildMessageItem(message, isDark);
              },
            ),
          ),

          // 3. 하단 입력 바
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  // 상단 상시 추천 질문 바
  Widget _buildPromptShelf(bool isDark) {
    final chipBg = isDark ? const Color(0xFF1E1E26) : Colors.white;
    final activeTabColor = const Color(0xFF6B4EE6);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: isDark ? const Color(0xFF191920) : const Color(0xFFF0F0F4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 필터 탭
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;

                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: isSelected ? activeTabColor : chipBg,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: isSelected
                            ? activeTabColor
                            : (isDark ? Colors.white24 : Colors.black12),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.grey[400] : Colors.grey[700]),
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // 세분화된 질문 칩 가로 리스트
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              itemCount: _filteredPrompts.length,
              itemBuilder: (context, index) {
                final prompt = _filteredPrompts[index];
                return GestureDetector(
                  onTap: () => _handleUserMessage(prompt.queryText),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262632) : Colors.white,
                      borderRadius: BorderRadius.circular(18.0),
                      border: Border.all(
                        color: isDark ? const Color(0xFF3E3E4E) : Colors.grey[300]!,
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      prompt.label,
                      style: TextStyle(
                        color: isDark ? Colors.grey[200] : const Color(0xFF222222),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 메시지 아이템
  Widget _buildMessageItem(ChatMessage message, bool isDark) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF6B4EE6),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 챗봇 응답
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 도슨트 아바타
              Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4EE6).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF8B5CF6)),
                ),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  color: Color(0xFFA88BFA),
                  size: 20,
                ),
              ),

              // 텍스트 말풍선
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF22222C) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF191919),
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 1. 꼬리질문 동적 선택지 칩들 (있는 경우)
          if (message.followUpOptions != null &&
              message.followUpOptions!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 46.0, top: 10.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: message.followUpOptions!.map((option) {
                  return ActionChip(
                    backgroundColor:
                        isDark ? const Color(0xFF2E2E3C) : const Color(0xFFEDE9FE),
                    side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    label: Text(
                      option,
                      style: const TextStyle(
                        color: Color(0xFF6B4EE6),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _handleUserMessage(option),
                  );
                }).toList(),
              ),
            ),
          ],

          // 2. 추천 영화 카드들 (있는 경우)
          if (message.recommendedMovies != null &&
              message.recommendedMovies!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 46.0, top: 14.0),
              child: SizedBox(
                height: 230,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: message.recommendedMovies!.length,
                  itemBuilder: (context, idx) {
                    final movie = message.recommendedMovies![idx];
                    final reason = (message.movieReasons != null &&
                            idx < message.movieReasons!.length)
                        ? message.movieReasons![idx]
                        : '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailScreen(movie: movie),
                          ),
                        );
                      },
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12.0),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF282834) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 영화 포스터
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: SizedBox(
                                width: 140,
                                height: 140,
                                child: movie.fullPosterUrl.isNotEmpty
                                    ? Image.network(
                                        movie.fullPosterUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          color: Colors.grey[800],
                                          child: const Icon(
                                            Icons.movie,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          Icons.movie,
                                          color: Colors.white54,
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF191919),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Color(0xFFFFB800),
                                        size: 13,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '평점 ${movie.voteAverage.toStringAsFixed(1)}',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (reason.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      reason,
                                      style: const TextStyle(
                                        color: Color(0xFFA88BFA),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 처리 중 인디케이터
  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 10.0),
            decoration: BoxDecoration(
              color: const Color(0xFF6B4EE6).withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF8B5CF6)),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Color(0xFFA88BFA),
              size: 20,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF22222C) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '맞춤 영화를 선별하고 있습니다...',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 하단 입력 바
  Widget _buildInputBar(bool isDark) {
    final barBg = isDark ? const Color(0xFF1A1A22) : Colors.white;
    final inputBg = isDark ? const Color(0xFF262632) : const Color(0xFFF2F2F6);
    final inputTextColor = isDark ? Colors.white : const Color(0xFF191919);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: TextField(
                  controller: _inputController,
                  style: TextStyle(color: inputTextColor, fontSize: 14),
                  onSubmitted: _handleUserMessage,
                  decoration: InputDecoration(
                    hintText: '영화에 대해 무엇이든 물어보세요',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            GestureDetector(
              onTap: () => _handleUserMessage(_inputController.text),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF6B4EE6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
