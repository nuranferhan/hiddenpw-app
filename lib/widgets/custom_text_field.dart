import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.obscureText = false,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late FocusNode _internalFocusNode;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    } else {
      _internalFocusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (_internalFocusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _internalFocusNode.hasFocus;
      });
      
      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  Color _getBorderColor(bool isDarkMode) {
    if (_hasError) return Colors.red;
    if (_isFocused) return Colors.blue;
    return isDarkMode 
        ? Colors.grey.withOpacity(0.5) 
        : Colors.grey.withOpacity(0.4);
  }

  Color _getLabelColor(bool isDarkMode) {
    if (_hasError) return Colors.red;
    if (_isFocused) return Colors.blue;
    return isDarkMode ? Colors.grey : Colors.grey[600]!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final backgroundColor = widget.enabled
        ? (isDarkMode ? const Color(0xFF2D2D2D) : Colors.grey.shade100)
        : (isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey.shade200);
    
    final textColor = widget.enabled
        ? (isDarkMode ? Colors.white : Colors.black87)
        : (isDarkMode ? Colors.grey : Colors.grey[600]!);
    
    final hintColor = isDarkMode 
        ? Colors.grey.withOpacity(0.7)
        : Colors.grey.withOpacity(0.8);

    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getBorderColor(isDarkMode),
                  width: _isFocused ? 2 : 1,
                ),
                color: backgroundColor,
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _internalFocusNode,
                obscureText: widget.obscureText,
                validator: (value) {
                  final error = widget.validator?.call(value);
                  setState(() {
                    _hasError = error != null;
                  });
                  return error;
                },
                maxLines: widget.maxLines,
                keyboardType: widget.keyboardType,
                onTap: widget.onTap,
                readOnly: widget.readOnly,
                enabled: widget.enabled,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: widget.hint,
                  labelStyle: TextStyle(
                    color: _getLabelColor(isDarkMode),
                    fontSize: _isFocused ? 14 : 16,
                    fontWeight: _isFocused ? FontWeight.w500 : FontWeight.normal,
                  ),
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: 16,
                  ),
                  prefixIcon: widget.icon != null
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            widget.icon,
                            color: _getLabelColor(isDarkMode),
                            size: 24,
                          ),
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: widget.icon != null ? 8 : 16,
                    vertical: widget.maxLines > 1 ? 16 : 20,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
              ),
            ),
            
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: _hasError ? 24 : 0,
              child: _hasError
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4, left: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.validator?.call(widget.controller.text) ?? '',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
          ],
        );
      },
    );
  }
}

class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool showGenerator;
  final VoidCallback? onGeneratePressed;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.showGenerator = true,
    this.onGeneratePressed,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Theme-aware icon colors
    final iconColor = isDarkMode ? Colors.grey : Colors.grey[600]!;

    return CustomTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      icon: Icons.lock,
      obscureText: !_isPasswordVisible,
      validator: widget.validator,
      onChanged: widget.onChanged,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showGenerator)
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: Colors.blue),
              onPressed: widget.onGeneratePressed,
              tooltip: 'Şifre Üret',
            ),
          IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: iconColor,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            tooltip: _isPasswordVisible ? 'Gizle' : 'Göster',
          ),
        ],
      ),
    );
  }
}