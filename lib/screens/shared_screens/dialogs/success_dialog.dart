import 'package:flutter/material.dart';
import '../../../constants/colors.dart';

class SuccessDialog {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onDone,
    bool isSuccess = true, // ✅ جديد
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ أيقونة (نجاح أو تحذير)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? AppColors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.info_outline,
                  color: isSuccess ? AppColors.green : Colors.orange,
                  size: 50,
                ),
              ),
              SizedBox(height: 24),

              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? AppColors.green : Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),

              Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onDone?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSuccess ? AppColors.green : Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
