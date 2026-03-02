import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class HandleBookingPage extends StatelessWidget {
  final String service;
  final String barber;
  final DateTime date;
  final String time;

  const HandleBookingPage({
    super.key,
    required this.service,
    required this.barber,
    required this.date,
    required this.time,
  });

  String _bookingId() =>
      '#BK-${Random().nextInt(900000) + 100000}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดการจอง')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_circle,
                  size: 80, color: Colors.green),
              const SizedBox(height: 12),
              const Text('จองสำเร็จ!',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Divider(),
              _row('บริการ', service),
              _row('ช่าง', barber),
              _row('วันที่',
                  DateFormat('yyyy-MM-dd').format(date)),
              _row('เวลา', time),
              const Divider(),
              Text(_bookingId(),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('กลับหน้าหลัก'),
              )
            ]),
          ),
        ),
      ),
    );
  }

  Widget _row(String l, String r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l),
              Text(r,
                  style:
                      const TextStyle(fontWeight: FontWeight.bold))
            ]),
      );
}