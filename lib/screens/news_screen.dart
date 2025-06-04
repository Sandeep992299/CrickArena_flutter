import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> _matches = [];
  bool _isLoading = true;
  bool _hasError = false;

  final String _apiKey = 'f20c166b-621b-41af-ac68-92b0f01b0e21';

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    final String url =
        'https://api.cricapi.com/v1/matches?apikey=$_apiKey&offset=0';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _matches = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_hasError) {
      return const Center(child: Text('Failed to load match data.'));
    } else if (_matches.isEmpty) {
      return const Center(child: Text('No matches available.'));
    } else {
      return ListView.builder(
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 3,
            child: ListTile(
              title: Text('${match['name'] ?? 'Unknown Match'}'),
              subtitle: Text('${match['status'] ?? 'Status unavailable'}'),
              trailing: Text('${match['date'] ?? ''}'),
            ),
          );
        },
      );
    }
  }
}
