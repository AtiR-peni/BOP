import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '収支表アプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<Expense>> _expenses = {};

  void addExpense(DateTime date, double amount, String tag, String memo) {
    setState(() {
      if (!_expenses.containsKey(date)) {
        _expenses[date] = [];
      }
      _expenses[date]!.add(Expense(amount: amount, tag: tag, memo: memo));
    });
  }

  double getBalance(DateTime date) {
    if (!_expenses.containsKey(date)) return 0.0;
    return _expenses[date]!.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('収支表カレンダー - 2024年'),
      ),
      body: GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
        itemCount: 12 * 31, // 12 months, up to 31 days each
        itemBuilder: (context, index) {
          int month = index ~/ 31 + 1;
          int day = index % 31 + 1;
          DateTime date = DateTime(2024, month, day);

          if (day > DateTime(2024, month + 1, 0).day) {
            return Container();
          }

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ExpenseEntryScreen(date: date, addExpense: addExpense),
              ),
            ),
            child: Card(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('MMM d').format(date)),
                    Text(
                      getBalance(date).toStringAsFixed(2),
                      style: TextStyle(
                        color:
                            getBalance(date) >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ExpenseEntryScreen extends StatelessWidget {
  final DateTime date;
  final Function addExpense;

  ExpenseEntryScreen({required this.date, required this.addExpense});

  final TextEditingController amountController = TextEditingController();
  final TextEditingController memoController = TextEditingController();

  final List<String> tags = ['パチンコ', 'スロット', '競馬', '競艇', '麻雀'];
  String selectedTag = 'パチンコ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy年MMM d日').format(date)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: '金額'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              value: selectedTag,
              items: tags.map((String tag) {
                return DropdownMenuItem<String>(
                  value: tag,
                  child: Text(tag),
                );
              }).toList(),
              onChanged: (newValue) {
                selectedTag = newValue!;
              },
              decoration: InputDecoration(labelText: 'タグ'),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: memoController,
              decoration: InputDecoration(labelText: 'メモ'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                double amount = double.parse(amountController.text);
                String memo = memoController.text;
                String tag = selectedTag;

                addExpense(date, amount, tag, memo);

                Navigator.pop(context);
              },
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}

class Expense {
  final double amount;
  final String tag;
  final String memo;

  Expense({required this.amount, required this.tag, required this.memo});
}
