import 'package:flutter/material.dart';
import 'order_confirmation_screen.dart';
import 'api_service.dart';

class MenuScreen extends StatefulWidget {
  final int tableNumber;

  MenuScreen({required this.tableNumber});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Map<int, int> orderItems = {}; // itemId -> quantity
  List<Map<String, dynamic>> menuItems = [];

  Future<void> fetchMenu() async {
    menuItems = await ApiService.getMenu();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เลือกเมนู', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[600],
        centerTitle: true,
      ),
      body: menuItems.isEmpty
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  var item = menuItems[index];
                  int itemId = int.tryParse(item['item_id'].toString()) ?? 0; 

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['item_name'],
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '฿${item['item_price']}',
                                style: TextStyle(fontSize: 18, color: Colors.green[700]),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    if (orderItems[itemId] != null && orderItems[itemId]! > 1) {
                                      orderItems[itemId] = orderItems[itemId]! - 1;
                                    } else {
                                      orderItems.remove(itemId);
                                    }
                                  });
                                },
                              ),
                              Text(
                                orderItems[itemId]?.toString() ?? '0',
                                style: TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                icon: Icon(Icons.add, color: Colors.green),
                                onPressed: () {
                                  setState(() {
                                    orderItems[itemId] = (orderItems[itemId] ?? 0) + 1;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (orderItems.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderConfirmationScreen(
                  tableNumber: widget.tableNumber,
                  orderItems: orderItems,
                  menu: menuItems,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('กรุณาเลือกเมนูก่อน', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        label: Text('ยืนยันการสั่ง', style: TextStyle(fontSize: 18)),
        icon: Icon(Icons.check),
        backgroundColor: Colors.green[600],
      ),
    );
  }
}
