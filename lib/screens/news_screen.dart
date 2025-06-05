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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("🏏 Cricket Live Matches"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 239, 229, 41),
                Color.fromARGB(255, 235, 197, 86),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF1F3F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.only(top: 100),
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.deepPurple),
                )
                : _hasError
                ? const Center(
                  child: Text(
                    '❌ Failed to load match data.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
                : _matches.isEmpty
                ? const Center(child: Text('No matches available.'))
                : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _matches.length,
                  itemBuilder: (context, index) {
                    final match = _matches[index];
                    return MatchCard(match: match);
                  },
                ),
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  final dynamic match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final String name = match['name'] ?? 'Unknown Match';
    final String status = match['status'] ?? 'Unknown';
    final String date = match['date'] ?? '';
    final String venue = match['venue'] ?? 'Unknown Venue';
    final String matchType = match['matchType'] ?? 'Unknown Type';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.deepPurple,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(status, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.deepPurple,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(date, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.sports_cricket,
                  color: Colors.deepPurple,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(matchType, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.place,
                  color: Color.fromARGB(255, 144, 74, 243),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(venue, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
