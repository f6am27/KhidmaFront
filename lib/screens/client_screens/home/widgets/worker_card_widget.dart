import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';

class WorkerCardWidget extends StatelessWidget {
  final Map<String, dynamic> worker;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onPhoneCall;
  final VoidCallback onChat;

  const WorkerCardWidget({
    Key? key,
    required this.worker,
    required this.onFavoriteToggle,
    required this.onPhoneCall,
    required this.onChat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? ThemeColors.shadowDark
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Worker image
          _buildWorkerImage(isDark),
          SizedBox(width: 12),

          // Worker details
          Expanded(
            child: _buildWorkerDetails(isDark),
          ),

          // Action buttons
          _buildActionButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildWorkerImage(bool isDark) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? ThemeColors.darkSurface : Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Icon(
          Icons.person,
          size: 30,
          color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildWorkerDetails(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatingRow(isDark),
        SizedBox(height: 4),
        _buildWorkerName(isDark),
        SizedBox(height: 4),
        _buildWorkerArea(isDark),
        SizedBox(height: 4),
        _buildPriceRow(isDark),
      ],
    );
  }

  Widget _buildRatingRow(bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 16,
        ),
        SizedBox(width: 4),
        Text(
          worker['rating'].toString(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark
                ? ThemeColors.darkTextPrimary
                : ThemeColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerName(bool isDark) {
    return Text(
      worker['name'],
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color:
            isDark ? ThemeColors.darkTextPrimary : ThemeColors.lightTextPrimary,
      ),
    );
  }

  Widget _buildWorkerArea(bool isDark) {
    return Text(
      worker['area'],
      style: TextStyle(
        color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[600],
        fontSize: 12,
      ),
    );
  }

  Widget _buildPriceRow(bool isDark) {
    return Text(
      worker['price'] + '/heure',
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: ThemeColors.successColor,
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Heart (Favorite) button
        GestureDetector(
          onTap: onFavoriteToggle,
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              worker['isFavorite'] ? Icons.favorite : Icons.favorite_border,
              color: worker['isFavorite']
                  ? Colors.red
                  : (isDark ? ThemeColors.darkTextSecondary : Colors.grey[600]),
              size: 20,
            ),
          ),
        ),

        SizedBox(width: 4), // مسافة صغيرة بين الأيقونات

        // Phone button
        GestureDetector(
          onTap: onPhoneCall,
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.phone,
              color: ThemeColors.successColor,
              size: 20,
            ),
          ),
        ),

        SizedBox(width: 4), // مسافة صغيرة بين الأيقونات

        // Chat button
        GestureDetector(
          onTap: onChat,
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.chat_bubble_outline,
              color: ThemeColors.primaryColor,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
