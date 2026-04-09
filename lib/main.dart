import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class Txn {
  String name, pan, date;
  double amount, tds, net;

  Txn(this.name, this.pan, this.amount)
      : tds = amount * 0.01,
        net = amount - (amount * 0.01),
        date = DateFormat('dd-MM-yyyy').format(DateTime.now());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto TDS Ledger India',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Txn> list = [];

  final name = TextEditingController();
  final pan = TextEditingController();
  final amt = TextEditingController();

  void add() {
    if (name.text.isEmpty || pan.text.isEmpty || amt.text.isEmpty) return;

    setState(() {
      list.add(Txn(name.text, pan.text, double.parse(amt.text)));
    });

    name.clear();
    pan.clear();
    amt.clear();
  }

  double totalTds() {
    return list.fold(0, (s, e) => s + e.tds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crypto TDS Ledger India')),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(controller: name, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: pan, decoration: InputDecoration(labelText: "PAN")),
            TextField(controller: amt, decoration: InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),

            SizedBox(height: 10),
            ElevatedButton(onPressed: add, child: Text("ADD")),

            SizedBox(height: 10),
            Text("Monthly TDS: ₹${totalTds().toStringAsFixed(2)}"),

            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (c, i) {
                  var t = list[i];
                  return Card(
                    child: ListTile(
                      title: Text("${t.name} ₹${t.amount}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("PAN: ${t.pan}"),
                          Text("TDS: ₹${t.tds} | Net: ₹${t.net}"),
                          Text("Date: ${t.date}"),
                          Text(
                            "1% TDS u/s 194S. Claim in ITR. Deposited monthly.",
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() => list.removeAt(i));
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
