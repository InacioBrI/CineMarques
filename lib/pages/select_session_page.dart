import 'package:flutter/material.dart';
import 'confirmation_page.dart';

class SelectSessionPage extends StatefulWidget {
  final String movieTitle;

  const SelectSessionPage({super.key, required this.movieTitle});

  @override
  State<SelectSessionPage> createState() => _SelectSessionPageState();
}

class _SelectSessionPageState extends State<SelectSessionPage> {
  int _selectedDayIndex = 0;
  int _selectedTimeIndex = 0;
  String _selectedSeat = 'E5';

  final List<String> _days = ['17', '18', '19', '20', '21'];
  final List<String> _weekdays = ['Fri', 'Sat', 'Sun', 'Mon', 'Tue'];
  final List<String> _times = ['13:00', '15:45', '18:50', '21:00'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.movieTitle,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text(
              'Select date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final bool selected = index == _selectedDayIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDayIndex = index);
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color:
                          selected ? const Color(0xFF3C2DE1) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF3C2DE1)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _weekdays[index],
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _days[index],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: selected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: const Text(
              'Select time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _times.length,
              itemBuilder: (context, index) {
                final bool selected = index == _selectedTimeIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedTimeIndex = index);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? Colors.red : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: selected ? Colors.red : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      _times[index],
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: const Text(
              'Select seat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Tela simplificada de assentos: apenas mostramos algumas linhas
                  for (var row in ['A', 'B', 'C', 'D', 'E'])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(row,
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(width: 8),
                          for (var seat = 1; seat <= 10; seat++)
                            _SeatDot(
                              label: '$row$seat',
                              selected: _selectedSeat == '$row$seat',
                              onTap: () {
                                setState(() => _selectedSeat = '$row$seat');
                              },
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap a seat to select',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, -2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C2DE1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  final date = _days[_selectedDayIndex];
                  final weekday = _weekdays[_selectedDayIndex];
                  final time = _times[_selectedTimeIndex];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConfirmationPage(
                        movieTitle: widget.movieTitle,
                        dateLabel: '$weekday $date',
                        time: time,
                        seat: _selectedSeat,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatDot extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SeatDot({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color:
              selected ? const Color(0xFF3C2DE1) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
