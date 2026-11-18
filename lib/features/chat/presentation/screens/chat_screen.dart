import 'package:filmcock_app/features/chat/presentation/widgets/chat_message_tile.dart';
import 'package:filmcock_app/features/chat/application/chat_session_controller.dart';
import 'package:filmcock_app/app/dependencies/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:filmcock_app/features/chat/data/curated_movie_catalog.dart';
import 'package:filmcock_app/features/chat/domain/chat_message.dart';
import 'package:filmcock_app/features/movie_detail/presentation/screens/movie_detail_screen.dart';
import 'package:filmcock_app/shared/presentation/widgets/app_loading_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatSessionController _session = ChatSessionController(
    createService: AppDependencies.createChatbot,
  );

  List<ChatMessage> get _messages => _session.messages;
  bool get _isProcessing => _session.isProcessing;
  String _selectedCategory = '전체';

  final List<String> _categories = ['전체', '기분', '상황', '테마', 'MBTI'];

  @override
  void initState() {
    super.initState();
    _session.addListener(_onSessionChanged);
  }

  void _onSessionChanged() {
    if (!mounted) return;
    setState(() {});
    _scrollToBottom();
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    _session.dispose();
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

  Future<void> _handleUserMessage(String userText, {String? promptId}) async {
    if (userText.trim().isEmpty || _isProcessing) return;
    _inputController.clear();
    await _session.send(userText, promptId: promptId);
  }

  void _resetChat() {
    _session.reset();
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
    final colors = Theme.of(context).colorScheme;
    final bgColor = colors.surface;
    final appBarColor = colors.surfaceContainer;
    final textColor = colors.onSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          tooltip: '뒤로 가기',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '필름콕 영화 도슨트',
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
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
    final colors = Theme.of(context).colorScheme;
    final chipBg = colors.surfaceContainer;
    final activeTabColor = colors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: colors.surfaceContainerLow,
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
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
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
                  onTap: () =>
                      _handleUserMessage(prompt.queryText, promptId: prompt.id),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262632) : Colors.white,
                      borderRadius: BorderRadius.circular(18.0),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF3E3E4E)
                            : Colors.grey[300]!,
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      prompt.label,
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey[200]
                            : const Color(0xFF222222),
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
  Widget _buildMessageItem(ChatMessage message, bool isDark) => ChatMessageTile(
    message: message,
    onFollowUp: (option) => _handleUserMessage(option),
    onMovieTap: (movie) => Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie))),
  );

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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
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
                  child: AppLoadingIndicator(
                    label: '영화 추천 답변을 준비하는 중입니다.',
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
          top: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
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
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
