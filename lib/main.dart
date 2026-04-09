// FULL FINAL SUPER APP (shortened but complete logic)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginPage());
  }
}

// 🔐 LOGIN PAGE
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();

  void login() async {
    await FirebaseAuth.instance.signInAnonymously();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: login,
          child: Text("ENTER APP"),
        ),
      ),
    );
  }
}

// 🏠 HOME
class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final name = TextEditingController();
  final pan = TextEditingController();
  final amt = TextEditingController();

  void add() async {
    double a = double.parse(amt.text);
    double t = a * 0.01;

    await FirebaseFirestore.instance.collection("txns").add({
      "name": name.text,
      "pan": pan.text,
      "amount": a,
      "tds": t,
      "net": a - t,
      "date": DateFormat('dd-MM-yyyy').format(DateTime.now()),
    });
  }

  // 📊 EXPORT CSV
  void exportCSV(List docs) async {
    List<List<dynamic>> rows = [
      ["Name", "PAN", "Amount", "TDS", "Net"]
    ];

    for (var d in docs) {
      rows.add([
        d['name'],
        d['pan'],
        d['amount'],
        d['tds'],
        d['net']
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/tds.csv");
    await file.writeAsString(csv);

    Share.shareXFiles([XFile(file.path)]);
  }

  // 📄 PDF
  void generatePDF(Map t) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Text(
            "Name: ${t['name']}\nAmount: ${t['amount']}\nTDS: ${t['tds']}"),
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'tds.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TDS PRO MAX")),
      body: Column(
        children: [
          TextField(controller: name),
          TextField(controller: pan),
          TextField(controller: amt),
          ElevatedButton(onPressed: add, child: Text("SAVE")),

          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("txns").snapshots(),
              builder: (c, s) {
                if (!s.hasData) return CircularProgressIndicator();

                var docs = s.data!.docs;

                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => exportCSV(docs.map((e)=>e.data()).toList()),
                      child: Text("EXPORT EXCEL"),
                    ),

                    Expanded(
                      child: ListView(
                        children: docs.map((e) {
                          var t = e.data();
                          return ListTile(
                            title: Text("${t['name']} ₹${t['amount']}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    icon: Icon(Icons.picture_as_pdf),
                                    onPressed: () => generatePDF(t)),
                                IconButton(
                                    icon: Icon(Icons.share),
                                    onPressed: () => Share.share(t.toString())),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
