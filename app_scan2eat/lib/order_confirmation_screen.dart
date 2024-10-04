import 'package:flutter/material.dart';
import 'payment_screen.dart';
import 'api_service.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final int tableNumber;
  final Map<int, int> orderItems;
  final List menu;

  OrderConfirmationScreen({
    required this.tableNumber,
    required this.orderItems,
    required this.menu,
  });

  double calculateTotalPrice() {
    double total = 0.0;
    orderItems.forEach((itemId, quantity) {
      final menuItem = menu.firstWhere(
        (item) => item['item_id'].toString() == itemId.toString(),
        orElse: () => Map<String, dynamic>.from({}),
      );

      if (menuItem.isNotEmpty) {
        final itemPrice = double.tryParse(menuItem['item_price'].toString()) ?? 0.0;
        total += itemPrice * quantity;
      }
    });
    return total;
  }

  Future<void> updateTableStatus(BuildContext context, String status) async {
    await ApiService.updateTableStatus(tableNumber, status);
  }

  Future<void> submitOrder(BuildContext context) async {
    final totalPrice = calculateTotalPrice();
    await updateTableStatus(context, 'not available');

    try {
      await ApiService.submitOrder(tableNumber, orderItems, totalPrice);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order submitted successfully!'),
        backgroundColor: Colors.green,
      ));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            tableNumber: tableNumber,
            totalPrice: totalPrice,
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ยืนยันออร์เดอร์'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: orderItems.length,
                itemBuilder: (context, index) {
                  final itemId = orderItems.keys.elementAt(index);
                  final quantity = orderItems[itemId] ?? 0; // ใช้ 0 หาก quantity เป็น null

                  final menuItem = menu.firstWhere(
                    (item) => item['item_id'].toString() == itemId.toString(),
                    orElse: () => Map<String, dynamic>.from({}),
                  );

                  if (menuItem.isEmpty) {
                    return Card(
                      color: Colors.red[100],
                      child: ListTile(
                        title: Text('Item not found for ID $itemId'),
                        subtitle: Text('Quantity: $quantity'),
                      ),
                    );
                  }

                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(
                        '${menuItem['item_name']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('จำนวนที่คุณเลือก: $quantity'),
                      trailing: Text(
                        '฿${(double.tryParse(menuItem['item_price'].toString()) ?? 0.0) * quantity}',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Total: ฿${calculateTotalPrice().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  submitOrder(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text('Submit Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
