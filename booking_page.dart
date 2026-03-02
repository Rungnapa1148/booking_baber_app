import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'handle_booking_page.dart';

/// ====== MOCK DATABASE ======
class BookingStore {
  static final List<Map<String, String>> bookings = [];

  static List<String> getOccupiedTimes(String barber, String date) {
    return bookings
        .where((b) => b['barber'] == barber && b['date'] == date)
        .map((b) => b['time']!)
        .toList();
  }

  static bool isBooked(String barber, String date, String time) {
    return bookings.any((b) =>
        b['barber'] == barber &&
        b['date'] == date &&
        b['time'] == time);
  }

  static void addBooking(String barber, String date, String time) {
    bookings.add({
      'barber': barber,
      'date': date,
      'time': time,
    });
  }
}

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  bool isDateSelected = false;

  String? selectedService;
  String? selectedBarber;
  String? selectedTime;
  String? selectedDate;

  List<String> occupiedSlots = [];

  final List<String> services = [
    'ตัดผมชาย',
    'ตัดผมหญิง',
    'สระไดร์',
    'ทำสีผม',
    'โกนหนวด'
  ];

  final List<String> barbers = [
    'ช่างเอ',
    'ช่างบี',
    'ช่างซี'
  ];

  final List<String> allTimeSlot = [
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  void loadOccupied() {
    if (selectedBarber == null) return;

    selectedDate = selectedDay.toIso8601String().split('T')[0];

    occupiedSlots =
        BookingStore.getOccupiedTimes(selectedBarber!, selectedDate!);

    setState(() {
      selectedTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('จองคิวทำผม')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ====== CALENDAR ======
            TableCalendar(
              focusedDay: focusedDay,
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 180 )),
              selectedDayPredicate: (day) =>
                  isSameDay(selectedDay, day),
              onDaySelected: (day, focus) {
                setState(() {
                  selectedDay = day;
                  focusedDay = focus;
                  isDateSelected = true;

                  // reset ทุกอย่างเมื่อเปลี่ยนวัน
                  selectedService = null;
                  selectedBarber = null;
                  selectedTime = null;
                  occupiedSlots.clear();
                });
              },
            ),

            if (!isDateSelected)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'กรุณาเลือกวันที่ก่อน',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            /// ====== SERVICE ======
            _title('เลือกรูปแบบบริการ'),
            _lockWrapper(
              child: _chipGroup(
                services,
                selectedService,
                (v) => setState(() => selectedService = v),
              ),
            ),

            /// ====== BARBER ======
            _title('เลือกช่าง'),
            _lockWrapper(
              child: _chipGroup(
                barbers,
                selectedBarber,
                (v) {
                  selectedBarber = v;
                  loadOccupied();
                },
                color: Colors.green,
              ),
            ),

            /// ====== TIME ======
            _title('เลือกเวลา'),
            _lockWrapper(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: allTimeSlot.length,
                itemBuilder: (_, i) {
                  final time = allTimeSlot[i];
                  final full = occupiedSlots.contains(time);
                  final selected = selectedTime == time;

                  return GestureDetector(
                    onTap: full
                        ? null
                        : () =>
                            setState(() => selectedTime = time),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: full
                            ? Colors.grey
                            : selected
                                ? Colors.blue
                                : Colors.white,
                        borderRadius:
                            BorderRadius.circular(8),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Text(time),
                    ),
                  );
                },
              ),
            ),

            /// ====== CONFIRM ======
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  child: const Text('ยืนยันการจอง'),
                  onPressed: () {
                    if (!isDateSelected ||
                        selectedService == null ||
                        selectedBarber == null ||
                        selectedTime == null) return;

                    if (BookingStore.isBooked(
                        selectedBarber!,
                        selectedDate!,
                        selectedTime!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('เวลานี้ถูกจองแล้ว')),
                      );
                      return;
                    }

                    BookingStore.addBooking(
                        selectedBarber!,
                        selectedDate!,
                        selectedTime!);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HandleBookingPage(
                          service: selectedService!,
                          barber: selectedBarber!,
                          date: selectedDay,
                          time: selectedTime!,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lockWrapper({required Widget child}) {
    return Opacity(
      opacity: isDateSelected ? 1 : 0.4,
      child: IgnorePointer(
        ignoring: !isDateSelected,
        child: child,
      ),
    );
  }

  Widget _title(String t) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          t,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );

  Widget _chipGroup(
    List<String> items,
    String? selected,
    Function(String) onSelect, {
    Color color = Colors.blue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: items.map((e) {
          return ChoiceChip(
            label: Text(e),
            selected: selected == e,
            selectedColor: color,
            onSelected: (_) => setState(() => onSelect(e)),
          );
        }).toList(),
      ),
    );
  }
}