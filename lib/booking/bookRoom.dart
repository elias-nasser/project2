import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_provider.dart';
import '../dashboard.dart';

final String _baseURL = 'https://nasserhotel.000webhostapp.com/';

class RoomBookingPage extends StatefulWidget {
  final Map<String, dynamic> room;

  RoomBookingPage({required this.room});

  @override
  _RoomBookingPageState createState() => _RoomBookingPageState();
}

class _RoomBookingPageState extends State<RoomBookingPage> {
  int numberOfGuests = 1;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();

  void update(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);

    return Theme(
        data: ThemeData(
          brightness:
              authProvider.isDarkMode ? Brightness.dark : Brightness.light,
          canvasColor:
              authProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        ),
        child: Scaffold(
            appBar: AppBar(
              title: Text('Room Booking - ${widget.room['RoomType']}'),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      '$_baseURL/assets/picture/RoomType/' +
                          widget.room['RoomImage'],
                      fit: BoxFit.cover,
                      height: 300,
                    ),
                    SizedBox(height: 16),
                    Text('Room Type: ${widget.room['RoomType']}'),
                    Text('Cost: \$${widget.room['Cost']} per night'),
                    SizedBox(height: 16),
                    Text(
                      'Please enter your details to book the room:',
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
                      decoration:
                          InputDecoration(labelText: 'Number of Guests'),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null &&
                                  pickedDate != checkInDate) {
                                setState(() {
                                  checkInDate = pickedDate;
                                });
                              }
                            },
                            child: Text(
                              checkInDate == null
                                  ? 'Check-In Date'
                                  : 'Check-In: ${checkInDate!.toLocal()}'
                                      .split(' ')[0],
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null &&
                                  pickedDate != checkOutDate) {
                                setState(() {
                                  checkOutDate = pickedDate;
                                });
                              }
                            },
                            child: Text(
                              checkOutDate == null
                                  ? 'Check-Out Date'
                                  : 'Check-Out: ${checkOutDate!.toLocal()}'
                                      .split(' ')[0],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Total Cost: \$${(int.parse(widget.room['Cost']) * (checkOutDate?.difference(checkInDate ?? DateTime.now()).inDays ?? 0)).toInt()}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        bookRoom(
                          update,
                          widget.room['RoomTypeId'],
                          _emailController.text,
                          _contactNoController.text,
                          numberOfGuests,
                          checkInDate ?? DateTime.now(),
                          checkOutDate ?? DateTime.now(),
                          (int.parse(widget.room['Cost']) *
                                  (checkOutDate
                                          ?.difference(
                                              checkInDate ?? DateTime.now())
                                          .inDays ??
                                      0))
                              .toInt(),
                          Provider.of<AuthProvider>(context, listen: false)
                                  .userId ??
                              '0',
                        );
                        update('Booking room: ${widget.room['RoomType']}');
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DashboardPage()));
                      },
                      child: Text('Book Room'),
                    ),
                  ],
                ),
              ),
            )));
  }
}

void bookRoom(
    Function(String text) updateUser,
    String room,
    String email,
    String contactNo,
    int numberOfGuests,
    DateTime checkIn,
    DateTime checkOut,
    int totalCost,
    String userId) async {
  try {
    final url = Uri.parse('$_baseURL/addBookRoom.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'roomTypeId': room,
        'email': email,
        'contactno': contactNo,
        'no_of_guest': numberOfGuests,
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'totalCost': totalCost,
        'userId': userId,
      }),
    );
    print(room);

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
