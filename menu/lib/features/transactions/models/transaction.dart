class Transaction {
  final int id;
  final String staffId;
  final String staffName;
  final int companyId;
  final String companyName;
  final int menuId;
  final String menuName;
  final num mealCost;
  final num companyDailyDiscount;
  final num usedDiscountToday;
  final num remainingDiscount;
  final num discountAmount;
  final num paidAmount;
  final int paymentMethod;
  final String paymentMethodName;
  final String receiptNo;
  final DateTime transTime;

  Transaction({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.companyId,
    required this.companyName,
    required this.menuId,
    required this.menuName,
    required this.mealCost,
    required this.companyDailyDiscount,
    required this.usedDiscountToday,
    required this.remainingDiscount,
    required this.discountAmount,
    required this.paidAmount,
    required this.paymentMethod,
    required this.paymentMethodName,
    required this.receiptNo,
    required this.transTime,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final company = json['company'] as Map<String, dynamic>;
    return Transaction(
      id: json['t_id'] as int,
      staffId: json['staff_id'] as String,
      staffName: json['staff_name'] as String,
      companyId: company['company_id'] as int,
      companyName: company['company_name'] as String,
      menuId: json['menu_id'] as int,
      menuName: json['menu_name'] as String,
      mealCost: json['meal_cost'] as num,
      companyDailyDiscount: json['company_daily_discount'] as num,
      usedDiscountToday: json['used_discount_today'] as num,
      remainingDiscount: json['remaining_discount'] as num,
      discountAmount: json['discount_amt'] as num,
      paidAmount: json['paid_amt'] as num,
      paymentMethod: json['payment_method'] as int,
      paymentMethodName: json['payment_method_name'] as String,
      receiptNo: json['receipt_no'] as String,
      transTime: DateTime.parse(json['trans_time'] as String),
    );
  }
}
