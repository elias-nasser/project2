import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../dashboard.dart';

final String _baseURL = 'https://nasserhotel.000webhostapp.com/';

class EventBookingPage extends StatefulWidget {
  final Map<String, dynamic> event;

  EventBookingPage({required this.event});

  @override
  _EventBookingPageState createState() => _EventBookingPageState();
}

class _EventBookingPageState extends State<EventBookingPage> {
  int numberOfGuests = 1;
  DateTime? eventDate;
  TimeOfDay? eventStartTime;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  String selectedTotalHours = '2-4 hrs';

  void update(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Booking - ${widget.event['EventType']}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                '$_baseURL/assets/picture/EventType/' +
                    widget.event['EventImage'],
                fit: BoxFit.cover,
                height: 300,
              ),
              SizedBox(height: 16),
              Text('Event Type: ${widget.event['EventType']}'),
              Text('Cost: \$${widget.event['Cost']}'),
              SizedBox(height: 16),
              Text(
                'Please enter your details to book the event:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _contactNoController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              DropdownButtonFormField<int>(
                value: numberOfGuests,
                onChanged: (value) {
                  setState(() {
                    numberOfGuests = value!;
                  });
                },
                items: [1, 2, 3, 4].map((guests) {
                  return DropdownMenuItem<int>(
                    value: guests,
                    child: Text('$guests Guest(s)'),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Number of Guests'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != eventDate) {
                    setState(() {
                      eventDate = pickedDate;
                    });
                  }
                },
                child: Text(
                  eventDate == null
                      ? 'Event Date'
                      : 'Event Date: ${eventDate!.toLocal()}'.split(' ')[0],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null && pickedTime != eventStartTime) {
                    setState(() {
                      eventStartTime = pickedTime;
                    });
                  }
                },
                child: Text(
                  eventStartTime == null
                      ? 'Event Starting Time'
                      : 'Event Starting Time: ${eventStartTime!.format(context)}',
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTotalHours,
                onChanged: (value) {
                  setState(() {
                    selectedTotalHours = value!;
                  });
                },
                items: ['2-4 hrs', '4-8 hrs', '8-16 hrs', '16-24 hrs']
                    .map((hours) {
                  return DropdownMenuItem<String>(
                    value: hours,
                    child: Text(hours),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Total Hours'),
              ),
              SizedBox(height: 16),
              Text(
                'Total Cost: \$${(int.parse(widget.event['Cost']) * _calculateTotalHours(selectedTotalHours)).toInt()}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  bookEvent(
                    context,
                    update,
                    widget.event['EventTypeId'],
                    _emailController.text,
                    _contactNoController.text,
                    numberOfGuests,
                    eventDate ?? DateTime.now(),
                    eventStartTime ?? TimeOfDay.now(),
                    selectedTotalHours,
                    (int.parse(widget.event['Cost']) *
                            _calculateTotalHours(selectedTotalHours))
                        .toInt(),
                    Provider.of<AuthProvider>(context, listen: false).userId ??
                        '0',
                  );
                  print('Booking event: ${widget.event['EventType']}');
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => DashboardPage()));
                },
                child: Text('Book Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateTotalHours(String selectedHours) {
    switch (selectedHours) {
      case '2-4 hrs':
        return 4;
      case '4-8 hrs':
        return 8;
      case '8-16 hrs':
        return 16;
      case '16-24 hrs':
        return 24;
      default:
        return 4;
    }
  }
}

void bookEvent(
  BuildContext context,
  Function(String text) updateUser,
  String eventTypeId,
  String email,
  String contactNo,
  int numberOfGuests,
  DateTime eventDate,
  TimeOfDay eventStartTime,
  String selectedTotalHours,
  int totalCost,
  String userId,
) async {
  try {
    final url = Uri.parse('$_baseURL/addBookEvent.php');
    final formattedStartTime =
        '${eventStartTime!.hour.toString().padLeft(2, '0')}:${eventStartTime!.minute.toString().padLeft(2, '0')}';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'eventTypeId': eventTypeId,
        'email': email,
        'contactno': contactNo,
        'no_of_guest': numberOfGuests,
        'eventDate': eventDate.toIso8601String(),
        'eventStartTime': formattedStartTime,
        'totalHours': int.parse(selectedTotalHours.split('-')[0]),
        'totalCost': totalCost,
        'userId': userId,
      }),
    );
    print('data: ${jsonEncode({
          'eventTypeId': eventTypeId,
          'email': email,
          'contactno': contactNo,
          'no_of_guest': numberOfGuests,
          'eventDate': eventDate.toIso8601String(),
          'eventStartTime': formattedStartTime,
          'totalHours': int.parse(selectedTotalHours.split('-')[0]),
          'totalCost': totalCost,
          'userId': userId,
        })}');

    if (response.statusCode == 200) {
      print('Server response: ${response.body}');
      updateUser(response.body);
    } else {
      updateUser(
          'Failed to send booking details. Server returned status ${response.statusCode}');
    }
  } catch (e) {
    updateUser('Error sending booking details: $e');
  }
}
