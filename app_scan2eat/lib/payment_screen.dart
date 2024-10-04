import 'package:flutter/material.dart';
import 'api_service.dart';

class PaymentScreen extends StatelessWidget {
  final int tableNumber;
  final double totalPrice;

  PaymentScreen({
    required this.tableNumber,
    required this.totalPrice,
  });

  Future<void> processPayment(BuildContext context) async {
    try {
      final paymentSuccess = await ApiService.payAndUpdateStatus(tableNumber);

      if (paymentSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Payment completed! Table is now available.'),
          backgroundColor: Colors.green,
        ));

        // Navigate back to the main dashboard or a success screen
        Navigator.pop(context); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Payment failed. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error processing payment: $error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ชำระเงิน'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'โต๊ะที่: $tableNumber',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            Text(
              '', //Total: ฿${totalPrice.toStringAsFixed(2)}
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                processPayment(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,  // เปลี่ยนจาก primary เป็น backgroundColor
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: Icon(Icons.payment, size: 24),
              label: Text('Pay Now'),
            ),
            SizedBox(height: 20),
            Text(
              'เรียนลูกค้า สามารถสั่งอาหารเพิ่มเติมได้ หากต้องการเช็คบิลกรุณาไปที่เคาท์เตอร์เพื่อจ่ายเงิน',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
