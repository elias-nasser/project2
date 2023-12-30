import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'auth/auth_provider.dart';
import 'navigationDrawer/navigation_drawer.dart';

final String _baseURL = 'https://nasserhotel.000webhostapp.com';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? dashboardData;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final userId =
          Provider.of<AuthProvider>(context, listen: false).userId ?? '0';
      final response = await http
          .get(Uri.parse('$_baseURL/getDashboard.php?userId=$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          dashboardData = data;
        });
      } else {
        print(
            'Failed to load dashboard data. Server returned status ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> refreshData() async {
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: navigationDrawer(),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: refreshData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (dashboardData != null &&
                          dashboardData!['roomBookingStatus'] != null)
                        DashboardBox(
                          title: 'Room Booking',
                          data: dashboardData!['roomBookingStatus'],
                        ),
                      SizedBox(height: 16),
                      if (dashboardData != null &&
                          dashboardData!['eventBookingStatus'] != null)
                        DashboardBox(
                          title: 'Event Booking',
                          data: dashboardData!['eventBookingStatus'],
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class DashboardBox extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;

  DashboardBox({
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          DashboardItem(
            title: 'Total Booking',
            value: data['total'],
          ),
          DashboardItem(
            title: 'Booked Booking',
            value: data['Booked'],
          ),
          DashboardItem(
            title: 'Paid Booking',
            value: data['Paid'],
          ),
          DashboardItem(
            title: 'Rejected Booking',
            value: data['Rejected'],
          ),
          DashboardItem(
            title: 'Cancelled Booking',
            value: data['Cancelled'],
          ),
          DashboardItem(
            title: 'Checked Out Booking',
            value: data['CheckedOut'],
          ),
        ],
      ),
    );
  }
}

class DashboardItem extends StatelessWidget {
  final String title;
  final dynamic value;

  DashboardItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
