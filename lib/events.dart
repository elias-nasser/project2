import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:project2/navigationDrawer/navigation_drawer.dart';
import '../auth/sign_up.dart';
import 'booking/bookEvent.dart';
import 'booking/bookRoom.dart';

class ShowEvents extends StatefulWidget {
  @override
  _ShowEventsState createState() => _ShowEventsState();
}

class _ShowEventsState extends State<ShowEvents> {
  bool _loading = false;
  final List<Map<String, dynamic>> _events = [];
  final String _baseURL = 'https://nasserhotel.000webhostapp.com/';

  @override
  void initState() {
    super.initState();
    updateEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Events'),
        centerTitle: true,
      ),
      drawer: navigationDrawer(),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await updateEvents();
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: _events.map((event) {
                    return buildEvent(event);
                  }).toList(),
                ),
              ),
            ),
    );
  }

  Widget buildEvent(Map<String, dynamic> event) {
    int availableEvents = int.parse(event['avail_events'].toString());

    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Image.network(
            _baseURL + '/assets/picture/EventType/' + event['EventImage'],
            fit: BoxFit.cover,
            width: double.infinity,
            height: 150,
          ),
          SizedBox(height: 10),
          Text(event['EventType']),
          Text('\$${event['Cost']}/per ticket'),
          Text(
            'Available: ${event['avail_events']}/${event['count_events']}',
            style: TextStyle(
              color: availableEvents > 0 ? Colors.green : Colors.red,
            ),
          ),
          Text('Description: ${event['Description']}'),
          ElevatedButton(
            onPressed: availableEvents > 0
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventBookingPage(event: event),
                      ),
                    )
                : null,
            child: Text('Book Ticket'),
          ),
        ],
      ),
    );
  }

  Future<void> updateEvents() async {
    setState(() {
      _loading = true;
    });

    try {
      final url = Uri.parse('$_baseURL/getEvents.php');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonResponse = convert.jsonDecode(response.body);

        final List<Map<String, dynamic>> events =
            (jsonResponse as List<dynamic>).map((row) {
          return {
            'EventType': row['EventType'],
            'EventTypeId': row['EventTypeId'],
            'Cost': row['Cost'],
            'EventImage': row['EventImage'],
            'count_events': row['count_events'],
            'Description': row['Description'],
            'avail_events': row['avail_events'],
          };
        }).toList();
        print('Response body: ${response.body}');

        setState(() {
          _events.clear();
          _events.addAll(events);
        });
      }
    } catch (e) {
      print('Error fetching events: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }
}
