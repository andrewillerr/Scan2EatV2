import 'package:flutter/material.dart';
import 'menu_screen.dart';
import 'api_service.dart';

class TableSelectionScreen extends StatefulWidget {
  @override
  _TableSelectionScreenState createState() => _TableSelectionScreenState();
}

class _TableSelectionScreenState extends State<TableSelectionScreen> {
  int? selectedTable;
  List<Map<String, dynamic>> tables = [];

  Future<void> fetchTables() async {
    try {
      List<Map<String, dynamic>> fetchedTables = await ApiService.getAvailableTables();
      setState(() {
        tables = fetchedTables;
      });
    } catch (e) {
      throw Exception('Failed to load available tables: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTables();  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Scan2Eat', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[600],
        centerTitle: true,
      ),
      body: tables.isEmpty
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('เลือกโต๊ะของคุณ', 
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87)),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: DropdownButton<int>(
                      value: selectedTable,
                      hint: Text('กรุณาเลือกโต๊ะ', style: TextStyle(color: Colors.green[900])),
                      dropdownColor: Colors.green[50],
                      isExpanded: true,
                      underline: SizedBox(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedTable = newValue;
                        });
                      },
                      items: tables.map((table) {
                        var tableNumber = table['table_number'];
                        var status = table['status'];
                        int? tableNumberInt = int.tryParse(tableNumber.toString());
                        return DropdownMenuItem<int>(
                          value: tableNumberInt,
                          child: Text('โต๊ะ $tableNumberInt - สถานะ: $status', style: TextStyle(fontSize: 18)),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedTable != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuScreen(tableNumber: selectedTable!),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('กรุณาเลือกโต๊ะก่อน', style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('ยืนยัน'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
