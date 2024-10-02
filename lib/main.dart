import 'package:flutter/material.dart';
import 'package:finance_tracker_app/database_handler/expenses_handler.dart';
import 'package:finance_tracker_app/model/expenses_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ExpenseTracker(),
    );
  }
}

class ExpenseTracker extends StatefulWidget {
  const ExpenseTracker({super.key});

  @override
  _ExpenseTrackerState createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Expense> _expenses = [];
  final _formKey = GlobalKey<FormState>();
  double _amount = 0.0;
  String _category = 'Food';
  String _date = '';
  String _notes = '';
  int _selectedIndex = 0;
  int? _editingExpenseId;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() async {
    _expenses = await _dbHelper.getExpenses();
    setState(() {});
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Expense expense = Expense(
        id: _editingExpenseId,
        amount: _amount,
        category: _category,
        date: _date,
        notes: _notes,
      );
      if (_editingExpenseId == null) {
        _dbHelper.insertExpense(expense).then((_) {
          _loadExpenses();
          Navigator.of(context).pop();
        });
      } else {
        _dbHelper.updateExpense(expense).then((_) {
          _loadExpenses();
          Navigator.of(context).pop();
        });
      }
    }
  }

  void _showExpenseDialog({Expense? expense}) {
    if (expense != null) {
      _amount = expense.amount;
      _category = expense.category;
      _date = expense.date;
      _notes = expense.notes;
      _editingExpenseId = expense.id;
    } else {
      _amount = 0.0;
      _category = 'Food';
      _date = '';
      _notes = '';
      _editingExpenseId = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(expense == null ? 'Add Expense' : 'Edit Expense'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: expense?.amount.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(color: Colors.teal),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Please enter an amount' : null,
                    onSaved: (value) => _amount = double.parse(value!),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _category,
                    items: ['Food', 'Transport', 'Entertainment']
                        .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: Colors.teal),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _category = value!),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: expense?.date,
                    decoration: const InputDecoration(
                      labelText: 'Date (YYYY-MM-DD)',
                      labelStyle: TextStyle(color: Colors.teal),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter a date' : null,
                    onSaved: (value) => _date = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: expense?.notes,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      labelStyle: TextStyle(color: Colors.teal),
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _notes = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _saveExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(int id) {
    _dbHelper.deleteExpense(id).then((_) {
      _loadExpenses();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Expenses List
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _expenses.isEmpty
                ? const Center(child: Text('No expenses yet, start adding!', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15),
                          title: Text('${expense.amount} - ${expense.category}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Text('Date: ${expense.date}', style: TextStyle(color: Colors.teal.shade400)),
                              const SizedBox(height: 5),
                              Text('Notes: ${expense.notes}', style: const TextStyle(color: Colors.black54)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showExpenseDialog(expense: expense),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteExpense(expense.id!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Add Expense
          const Center(
            child: Text('Add Expense Page'),
          ),
          // Profile
          // ProfilePage(),  // Add the profile page
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Expenses'),
          // BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Expense'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showExpenseDialog(),
              backgroundColor: Colors.teal,
              child: Icon(Icons.add,color: Colors.white,),
            )
          : null,
    );
  }
}
