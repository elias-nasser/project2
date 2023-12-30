import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:provider/provider.dart';

import 'package:project2/navigationDrawer/navigation_drawer.dart';
import 'auth/auth_provider.dart';
import 'booking/bookRoom.dart';

class ShowRooms extends StatefulWidget {
  @override
  _ShowRoomsState createState() => _ShowRoomsState();
}

class _ShowRoomsState extends State<ShowRooms> {
  bool _loading = false;
  final List<Map<String, dynamic>> _rooms = [];
  final String _baseURL = 'https://nasserhotel.000webhostapp.com/';

  @override
  void initState() {
    super.initState();
    updateRooms();
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    print('User ID: ${authProvider.userId}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Rooms'),
        centerTitle: true,
      ),
      drawer: navigationDrawer(),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await updateRooms();
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: _rooms.map((room) {
                    return buildRoom(room);
                  }).toList(),
                ),
              ),
            ),
    );
  }

  Widget buildRoom(Map<String, dynamic> room) {
    int availableRooms = int.parse(room['avail_rooms'].toString());

    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(
            10),
      ),
      child: Column(
        children: [
          Image.network(
            _baseURL + '/assets/picture/RoomType/' + room['RoomImage'],
            fit: BoxFit.cover,
            width: double.infinity,
            height: 150,
          ),
          SizedBox(height: 10),
          Text(room['RoomType']),
          Text('\$${room['Cost']}/per night'),
          Text(
            'Available: ${room['avail_rooms']}/${room['count_rooms']}',
            style: TextStyle(
              color: availableRooms > 0 ? Colors.green : Colors.red,
            ),
          ),
          Text('Facilities: ${room['Description']}'),
          ElevatedButton(
            onPressed: availableRooms > 0
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomBookingPage(room: room),
                      ),
                    )
                : null,
            child: Text('Book'),
          ),
        ],
      ),
    );
  }

  Future<void> updateRooms() async {
    setState(() {
      _loading = true;
    });

    try {
      final url = Uri.parse('$_baseURL/getRooms.php');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonResponse = convert.jsonDecode(response.body);

        final List<Map<String, dynamic>> rooms =
            (jsonResponse as List<dynamic>).map((row) {
          return {
            'RoomType': row['RoomType'],
            'RoomTypeId': row['RoomTypeId'],
            'Cost': row['Cost'],
            'RoomImage': row['RoomImage'],
            'count_rooms': row['count_rooms'],
            'Description': row['Description'],
            'avail_rooms': row['avail_rooms'],
          };
        }).toList();
        print('Response body: ${response.body}');

        setState(() {
          _rooms.clear();
          _rooms.addAll(rooms);
        });
      }
    } catch (e) {
      print('Error fetching rooms: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
