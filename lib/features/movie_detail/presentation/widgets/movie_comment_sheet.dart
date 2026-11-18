import 'package:flutter/material.dart';

class MovieCommentSheet extends StatefulWidget {
  final String movieTitle;
  final Future<void> Function(String) onSubmit;

  const MovieCommentSheet({
    super.key,
    required this.movieTitle,
    required this.onSubmit,
  });

  @override
  State<MovieCommentSheet> createState() => _MovieCommentSheetState();
}

class _MovieCommentSheetState extends State<MovieCommentSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = '댓글 내용을 입력해주세요.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSubmit(text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) setState(() => _error = '댓글을 저장하지 못했습니다. 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '댓글 작성',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                tooltip: '닫기',
                icon: const Icon(Icons.close),
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Text(
            widget.movieTitle,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            enabled: !_saving,
            decoration: InputDecoration(
              hintText: '이 영화에 대한 감상평을 솔직하게 남겨보세요!',
              errorText: _error,
              filled: true,
              fillColor: colors.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _saving ? null : _submit,
              child: Text(_saving ? '저장 중' : '등록하기'),
            ),
          ),
        ],
      ),
    );
  }
}
