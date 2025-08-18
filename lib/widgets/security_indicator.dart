import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class SecurityIndicator extends StatelessWidget {
  final String password;
  final bool showDetails;

  const SecurityIndicator({
    super.key,
    required this.password,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final cardColor = isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.grey : Colors.grey[600];
    final borderColor = isDarkMode 
        ? Colors.grey.withOpacity(0.3) 
        : Colors.grey.withOpacity(0.3);
    final progressBarBackgroundColor = isDarkMode 
        ? Colors.grey[800] 
        : Colors.grey[300];

    final strength = PasswordHelpers.calculatePasswordStrength(password);
    final strengthText = PasswordHelpers.getPasswordStrengthText(password);
    final strengthColor = PasswordHelpers.getPasswordStrengthColor(password);
    final suggestions = PasswordHelpers.getPasswordSuggestions(password);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      
          Row(
            children: [
              Icon(
                _getStrengthIcon(strength),
                color: strengthColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Şifre Güvenliği',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: strengthColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: strengthColor),
                ),
                child: Text(
                  strengthText,
                  style: TextStyle(
                    color: strengthColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Güvenlik Seviyesi',
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                  Text(
                    '${(strength * 100).round()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: strengthColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildStrengthBar(strength, strengthColor, progressBarBackgroundColor!),
            ],
          ),

          if (showDetails) ...[
            const SizedBox(height: 16),

            _buildPasswordAnalysis(primaryTextColor),

            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSuggestions(suggestions, primaryTextColor, isDarkMode),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStrengthBar(double strength, Color color, Color backgroundColor) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          FractionallySizedBox(
            widthFactor: strength,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordAnalysis(Color primaryTextColor) {
    final analysis = PasswordHelpers.analyzePassword(password);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analiz',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildAnalysisChip(
              'Uzunluk: ${password.length}',
              analysis['hasGoodLength'] == true,
            ),
            _buildAnalysisChip(
              'Büyük Harf',
              analysis['hasUppercase'] == true,
            ),
            _buildAnalysisChip(
              'Küçük Harf',
              analysis['hasLowercase'] == true,
            ),
            _buildAnalysisChip(
              'Sayı',
              analysis['hasNumbers'] == true,
            ),
            _buildAnalysisChip(
              'Sembol',
              analysis['hasSymbols'] == true,
            ),
            _buildAnalysisChip(
              'Çeşitlilik',
              analysis['hasVariety'] == true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisChip(String label, bool isGood) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isGood 
          ? Colors.green.withOpacity(0.2)
          : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isGood ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGood ? Icons.check : Icons.close,
            size: 14,
            color: isGood ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isGood ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(List<String> suggestions, Color primaryTextColor, bool isDarkMode) {
    final suggestionTextColor = isDarkMode ? Colors.grey[300] : Colors.grey[700];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text(
              'Öneriler',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...suggestions.map((suggestion) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion,
                  style: TextStyle(
                    fontSize: 12,
                    color: suggestionTextColor,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  IconData _getStrengthIcon(double strength) {
    if (strength >= 0.8) {
      return Icons.security;
    } else if (strength >= 0.6) {
      return Icons.shield;
    } else if (strength >= 0.4) {
      return Icons.warning;
    } else {
      return Icons.error;
    }
  }
}