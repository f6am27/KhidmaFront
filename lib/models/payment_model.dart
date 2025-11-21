// lib/models/payment_model.dart

class PaymentModel {
  final int id;
  final String taskTitle;
  final String serviceType;
  final double amount;
  final String paymentMethod;
  final String paymentMethodDisplay;
  final String status;
  final String payerName;
  final String receiverName;
  final DateTime createdAt;
  final String? transactionId;
  final String? moosylTransactionId;
  final String? publishableKey;

  PaymentModel({
    required this.id,
    required this.taskTitle,
    required this.serviceType,
    required this.amount,
    required this.paymentMethod,
    required this.paymentMethodDisplay,
    required this.status,
    required this.payerName,
    required this.receiverName,
    required this.createdAt,
    this.transactionId,
    this.moosylTransactionId,
    this.publishableKey,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int,
      taskTitle: json['task_title'] as String? ?? 'Unknown Task',
      serviceType: json['service_type'] as String? ?? 'Unknown Service',
      amount: double.parse(json['amount'].toString()),
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      paymentMethodDisplay:
          json['payment_method_display'] as String? ?? 'Unknown',
      status: json['status'] as String? ?? 'pending',
      payerName: json['payer_name'] as String? ?? 'Unknown',
      receiverName: json['receiver_name'] as String? ?? 'Unknown',
      createdAt: DateTime.parse(json['created_at'] as String),
      transactionId: json['transaction_id'] as String?,
      moosylTransactionId: json['moosyl_transaction_id'] as String?,
      publishableKey: json['publishable_key'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_title': taskTitle,
      'service_type': serviceType,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_method_display': paymentMethodDisplay,
      'status': status,
      'payer_name': payerName,
      'receiver_name': receiverName,
      'created_at': createdAt.toIso8601String(),
      if (transactionId != null) 'transaction_id': transactionId,
      if (moosylTransactionId != null)
        'moosyl_transaction_id': moosylTransactionId,
      if (publishableKey != null) 'publishable_key': publishableKey,
    };
  }

  @override
  String toString() {
    return 'PaymentModel(id: $id, amount: $amount, status: $status)';
  }
}

class PaymentStatisticsModel {
  final String role;
  final double totalPaid;
  final double totalEarned;
  final int totalTransactions;
  final int completed;
  final int pending;
  final int cancelled;
  final double averagePerTransaction;
  final Map<String, int> paymentMethods;

  PaymentStatisticsModel({
    required this.role,
    this.totalPaid = 0.0,
    this.totalEarned = 0.0,
    required this.totalTransactions,
    required this.completed,
    required this.pending,
    required this.cancelled,
    required this.averagePerTransaction,
    required this.paymentMethods,
  });

  factory PaymentStatisticsModel.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String? ?? 'client';

    return PaymentStatisticsModel(
      role: role,
      totalPaid: double.parse(
          (json['total_paid'] ?? json['total_earned'] ?? 0).toString()),
      totalEarned: double.parse(
          (json['total_earned'] ?? json['total_paid'] ?? 0).toString()),
      totalTransactions: json['total_transactions'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      cancelled: json['cancelled'] as int? ?? 0,
      averagePerTransaction:
          double.parse(json['average_per_transaction'].toString()),
      paymentMethods:
          Map<String, int>.from(json['payment_methods'] as Map? ?? {}),
    );
  }

  double get totalAmount {
    if (role == 'client') return totalPaid;
    return totalEarned;
  }

  @override
  String toString() {
    return 'PaymentStatisticsModel(role: $role, total: $totalAmount, transactions: $totalTransactions)';
  }
}
