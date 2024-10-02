class Expense {
  int? id;
  double amount;
  String category;
  String date;
  String notes;

  Expense({this.id, required this.amount, required this.category, required this.date, required this.notes});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date,
      'notes': notes,
    };
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      date: map['date'],
      notes: map['notes'],
    );
  }
}
