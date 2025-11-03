import 'package:flutter/material.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../models/worker_search_model.dart';
import '../../../../services/favorite_workers_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared_screens/messages/chat_screen.dart';
import '../../../../services/chat_service.dart';
import '../../../../services/chat_service.dart';

class WorkerCardWidget extends StatefulWidget {
  final WorkerSearchResult worker; // ✅ تغيير من Map إلى Model
  final VoidCallback? onPhoneCall;
  final VoidCallback? onChat;
  final VoidCallback? onFavoriteChanged; // ✅ callback عند تغيير favorite

  const WorkerCardWidget({
    Key? key,
    required this.worker,
    this.onPhoneCall,
    this.onChat,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  State<WorkerCardWidget> createState() => _WorkerCardWidgetState();
}

class _WorkerCardWidgetState extends State<WorkerCardWidget> {
  final FavoriteWorkersService _favoriteService = FavoriteWorkersService();
  bool _isFavorite = false;
  bool _isTogglingFavorite = false;
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.worker.isFavorite;
    _checkIfBlocked();
  }

  @override
  void didUpdateWidget(WorkerCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.worker.isFavorite != widget.worker.isFavorite) {
      _isFavorite = widget.worker.isFavorite;
    }
  }

  Future<void> _checkIfBlocked() async {
    try {
      final result = await chatService.getBlockedUsers();

      if (result['ok']) {
        final blockedUsers = result['blocked_users'] as List<dynamic>;
        final blockedIds = <int>{};

        for (var user in blockedUsers) {
          // ✅ جرّب عدة احتمالات للـ structure
          int? blockedId;

          if (user is Map<String, dynamic>) {
            blockedId = user['blocked_user_id'] as int? ??
                user['blocked_user']?['id'] as int? ??
                user['id'] as int?;
          } else if (user is int) {
            blockedId = user;
          }

          if (blockedId != null) {
            blockedIds.add(blockedId);
          }
        }

        print(
            '✅ Blocked IDs: $blockedIds, Checking worker ID: ${widget.worker.id}');

        setState(() {
          _isBlocked = blockedIds.contains(widget.worker.id);
        });

        print('✅ Worker ${widget.worker.id} is blocked: $_isBlocked');
      }
    } catch (e) {
      print('❌ Error checking blocked status: $e');
    }
  }

  /// ✅ Toggle favorite مع Backend
  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite) return;
    // ✅ منع إضافة المحظور للمفضلة
    if (_isBlocked) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Vous ne pouvez pas ajouter un utilisateur bloqué aux favoris'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      final result = await _favoriteService.toggleFavorite(widget.worker.id);

      if (result['ok']) {
        setState(() {
          _isFavorite = result['is_favorite'];
        });

        // إظهار رسالة نجاح
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isFavorite
                    ? '${widget.worker.name} ajouté aux favoris'
                    : '${widget.worker.name} retiré des favoris',
              ),
              backgroundColor:
                  _isFavorite ? ThemeColors.primaryColor : Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // إشعار الـ parent widget
        widget.onFavoriteChanged?.call();
      } else {
        // في حالة فشل، عرض رسالة خطأ
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Erreur lors de la mise à jour'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error toggling favorite: $e');
    } finally {
      setState(() {
        _isTogglingFavorite = false;
      });
    }
  }

  Future<void> _makePhoneCall() async {
    // إزالة + وكود الدولة 222
    String cleanPhone = widget.worker.phone
        .replaceAll('+', '')
        .replaceAll('222', '')
        .trim(); // ✅ نفس التعديل

    final phoneNumber = 'tel://$cleanPhone';

    print('📞 Opening dialer with: $cleanPhone');

    try {
      if (await canLaunch(phoneNumber)) {
        await launch(phoneNumber);
        print('✅ Dialer opened successfully');
      } else {
        // جرّب النسخة البديلة
        final fallbackPhone = 'tel:$cleanPhone';
        if (await canLaunch(fallbackPhone)) {
          await launch(fallbackPhone);
          print('✅ Dialer opened with fallback');
        } else {
          throw 'Cannot launch dialer';
        }
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فتح تطبيق الهاتف: $cleanPhone'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _openChat(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final result = await chatService.startConversation(widget.worker.id);
    Navigator.pop(context); // أغلق Loading

    if (result['ok']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            conversationId: result['conversation_id'],
            contactName: widget.worker.name,
            contactId: widget.worker.id,
            isOnline: false,
            profileImageUrl: widget.worker.image,
          ),
        ),
      );
    } else {
      // ✅ تحقق من status code 403 أو رسالة block
      final errorMessage = (result['error'] ?? '').toString().toLowerCase();
      final statusCode = result['status'];

      String displayMessage;

      if (statusCode == 403 ||
          errorMessage.contains('block') ||
          errorMessage.contains('bloqué') ||
          errorMessage.contains('forbidden')) {
        displayMessage =
            'Vous ne pouvez pas discuter avec un utilisateur bloqué';
      } else {
        displayMessage =
            result['error'] ?? 'Erreur lors du démarrage de la conversation';
      }

      // ✅ عرض Dialog بدلاً من SnackBar
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.block, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Accès refusé',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: Text(
            displayMessage,
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  color: ThemeColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

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
        child: widget.worker.image != null && widget.worker.image!.isNotEmpty
            ? Image.network(
                widget.worker.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: 30,
                    color: isDark
                        ? ThemeColors.darkTextSecondary
                        : Colors.grey[600],
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(ThemeColors.primaryColor),
                    ),
                  );
                },
              )
            : Icon(
                Icons.person,
                size: 30,
                color:
                    isDark ? ThemeColors.darkTextSecondary : Colors.grey[600],
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
        _buildCategoryRow(isDark),
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
          widget.worker.rating.toStringAsFixed(1),
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
      widget.worker.name,
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
      widget.worker.area,
      style: TextStyle(
        color: isDark ? ThemeColors.darkTextSecondary : Colors.grey[600],
        fontSize: 12,
      ),
    );
  }

  Widget _buildCategoryRow(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.worker.category,
            style: TextStyle(
              color: ThemeColors.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ الأيقونات في صف واحد
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _isTogglingFavorite ? null : _toggleFavorite,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: _isTogglingFavorite
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(ThemeColors.primaryColor),
                        ),
                      )
                    : Icon(
                        _isBlocked
                            ? Icons.block
                            : (_isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border),
                        color: _isBlocked
                            ? Colors.grey
                            : (_isFavorite
                                ? Colors.red
                                : (isDark
                                    ? ThemeColors.darkTextSecondary
                                    : Colors.grey[600])),
                        size: 20,
                      ),
              ),
            ),
            SizedBox(width: 4),
            GestureDetector(
              onTap: _makePhoneCall,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.phone,
                  color: ThemeColors.successColor,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 4),
            GestureDetector(
              onTap: () => _openChat(context),
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
        ),

        // ✅ المسافة أسفل الأيقونات مباشرة
        if (widget.worker.distanceFromClient != null)
          Padding(
            padding: const EdgeInsets.only(
                top: 15.0, right: 2.0), // ← جرّب تغيير هذه القيم
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${widget.worker.distanceFromClient!.toStringAsFixed(1)} km',
                style: const TextStyle(
                  color: Colors.green, // اللون الأخضر كما أردت
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
