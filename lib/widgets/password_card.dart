import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_entry.dart';
import '../screens/password_detail_screen.dart';
import '../utils/helpers.dart';

class PasswordCard extends StatefulWidget {
  final PasswordEntry passwordEntry;
  final VoidCallback? onRefresh;

  const PasswordCard({
    super.key,
    required this.passwordEntry,
    this.onRefresh,
  });

  @override
  State<PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<PasswordCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    _navigateToDetail();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _navigateToDetail() async {
    print('Navigating to detail screen for: ${widget.passwordEntry.title}');
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordDetailScreen(
          passwordEntry: widget.passwordEntry,
        ),
      ),
    );
    
    print('Detail screen returned with result: $result');
    
    if (result != null && widget.onRefresh != null) {
      print('Calling onRefresh from password card');
      widget.onRefresh!();
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label panoya kopyalandı'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getInitials(String title) {
    if (title.isEmpty) return '?';
    
    final words = title.split(' ');
    if (words.length == 1) {
      return title.substring(0, 1).toUpperCase();
    } else {
      return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
    }
  }

  Color _getAvatarColor(String title) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    final index = title.hashCode % colors.length;
    return colors[index.abs()];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Theme-aware colors
    final cardColor = isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final tertiaryTextColor = isDarkMode ? Colors.grey[500] : Colors.grey[500];
    final borderColor = isDarkMode 
        ? Colors.grey.withOpacity(0.2) 
        : Colors.grey.withOpacity(0.3);
    final shadowColor = isDarkMode 
        ? Colors.black.withOpacity(0.1)
        : Colors.black.withOpacity(0.08);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.passwordEntry.isCompromised 
                    ? Colors.red.withOpacity(0.5)
                    : borderColor,
                  width: widget.passwordEntry.isCompromised ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: _getAvatarColor(widget.passwordEntry.title),
                          child: Text(
                            _getInitials(widget.passwordEntry.title),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Title and Username
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.passwordEntry.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: primaryTextColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.passwordEntry.isCompromised)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.red, width: 1),
                                      ),
                                      child: const Text(
                                        'İHLAL',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.passwordEntry.username,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Quick Actions
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              color: secondaryTextColor,
                              onPressed: () => _copyToClipboard(
                                widget.passwordEntry.username,
                                'Kullanıcı adı',
                              ),
                              tooltip: 'Kullanıcı adını kopyala',
                            ),
                            IconButton(
                              icon: const Icon(Icons.lock, size: 20),
                              color: secondaryTextColor,
                              onPressed: () => _copyToClipboard(
                                widget.passwordEntry.password,
                                'Şifre',
                              ),
                              tooltip: 'Şifreyi kopyala',
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Additional Info
                    if (widget.passwordEntry.url.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.link,
                            size: 16,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              PasswordHelpers.formatUrl(widget.passwordEntry.url),
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    if (widget.passwordEntry.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.note,
                            size: 16,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.passwordEntry.notes,
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    // Footer
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: tertiaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Güncellendi: ${PasswordHelpers.formatDate(widget.passwordEntry.updatedAt)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: tertiaryTextColor,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: PasswordHelpers.getPasswordStrengthColor(
                              widget.passwordEntry.password,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            PasswordHelpers.getPasswordStrengthText(
                              widget.passwordEntry.password,
                            ),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: PasswordHelpers.getPasswordStrengthColor(
                                widget.passwordEntry.password,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}