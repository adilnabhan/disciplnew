import 'dart:async';
import 'package:flutter/material.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/core/themes/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerChatScreen extends StatefulWidget {
  const CustomerChatScreen({
    required this.trainerId,
    required this.trainerName,
    this.conversationId,
    this.trainerPhoto,
    this.trainerPhone,
    super.key,
  });

  final int trainerId;
  final String trainerName;
  final int? conversationId;
  final String? trainerPhoto;
  final String? trainerPhone;

  @override
  State<CustomerChatScreen> createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
  int? _conversationId;
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    _initChat();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    if (_conversationId == null) {
      await _resolveConversation();
    } else {
      await _fetchMessages(showLoading: true);
    }

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_conversationId != null && mounted && !_isSending) {
        _fetchMessages(showLoading: false);
      }
    });
  }

  Future<void> _resolveConversation() async {
    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.chatDirect,
        data: {'trainer_id': widget.trainerId},
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final conv = data['conversation'] as Map<dynamic, dynamic>?;
        if (conv != null && conv['id'] != null) {
          setState(() {
            _conversationId = conv['id'] as int;
          });
          await _fetchMessages(showLoading: true);
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMessages({bool showLoading = false}) async {
    if (_conversationId == null) return;

    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await DioClient().dio.get<dynamic>(
        ApiUris.chatMessages(_conversationId!),
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final rawMsgs = data['messages'] as List<dynamic>? ?? [];

        final List<Map<String, dynamic>> parsed = rawMsgs
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        final bool hasNew = parsed.length != _messages.length;

        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.addAll(parsed);
            _isLoading = false;
          });

          if (hasNew) {
            _scrollToBottom();
          }
        }
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _conversationId == null) return;

    _textController.clear();
    setState(() {
      _isSending = true;
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'sender_role': 'customer',
        'is_me': true,
        'text': text,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
    });
    _scrollToBottom();

    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.chatMessages(_conversationId!),
        data: {'text': text},
        options: Options(headers: {'X-Platform': platformSource}),
      );

      if (response.statusCode == 201) {
        _fetchMessages(showLoading: false);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    return DateFormat('hh:mm a').format(dt.toLocal());
  }

  Future<void> _openWhatsApp() async {
    final phone = widget.trainerPhone;
    if (phone == null || phone.isEmpty) return;
    final cleanDigits = phone.replaceAll(RegExp(r'\D'), '');
    final fullPhone = cleanDigits.length == 10 ? '91$cleanDigits' : cleanDigits;
    final uri = Uri.parse('https://wa.me/$fullPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16161D),
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF262633),
              backgroundImage: widget.trainerPhoto != null && widget.trainerPhoto!.isNotEmpty
                  ? NetworkImage(widget.trainerPhoto!)
                  : null,
              child: widget.trainerPhoto == null || widget.trainerPhoto!.isEmpty
                  ? const Icon(Icons.person, color: Colors.white70, size: 20)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.trainerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF00E676), size: 7),
                      SizedBox(width: 4),
                      Text(
                        'Coach • In-App Chat',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (widget.trainerPhone != null && widget.trainerPhone!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 20),
              tooltip: 'Open WhatsApp',
              onPressed: _openWhatsApp,
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20),
            onPressed: () => _fetchMessages(showLoading: true),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(_messages[index]);
                          },
                        ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C24),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Direct Chat with ${widget.trainerName}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ask questions about your workout routine, diet plan, or schedule personal coaching sessions.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg['is_me'] == true || msg['sender_role'] == 'customer';
    final text = msg['text'] ?? '';
    final timeStr = _formatTime(msg['created_at']?.toString());
    final isRead = msg['is_read'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFF262633),
              backgroundImage: widget.trainerPhoto != null && widget.trainerPhoto!.isNotEmpty
                  ? NetworkImage(widget.trainerPhoto!)
                  : null,
              child: widget.trainerPhoto == null || widget.trainerPhoto!.isEmpty
                  ? const Icon(Icons.person, color: Colors.white70, size: 14)
                  : null,
            ),
          if (!isMe) const SizedBox(width: 6),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : const Color(0xFF1C1C24),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: Border.all(
                  color: isMe ? AppColors.primary.withOpacity(0.4) : Colors.white10,
                ),
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.black : Colors.white,
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: isMe ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: isMe ? Colors.black54 : Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isRead ? Icons.done_all_rounded : Icons.done_rounded,
                          size: 13,
                          color: isRead ? const Color(0xFF007BFF) : Colors.black45,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF16161D),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF22222E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Type a message to your coach...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.primary,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _isSending ? null : _sendMessage,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

