import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trip/root_pages/trip_pages/UserGoogleMapPageCustom.dart';

class CommunityPage extends StatefulWidget {
  final String userKey;

  const CommunityPage({
    Key? key,
    required this.userKey,
  }) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _communityRef =
  FirebaseDatabase.instance.ref().child('CommunityMessages');
  final DatabaseReference _usersRef =
  FirebaseDatabase.instance.ref().child('Users');
  bool _isLoading = true;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    _communityRef.onValue.listen((event) async {
      if (event.snapshot.value == null) {
        setState(() {
          _messages = [];
          _isLoading = false;
        });
        return;
      }

      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      List<Map<String, dynamic>> messages = [];

      for (var entry in data.entries) {
        try {
          final messageData = Map<String, dynamic>.from(entry.value as Map);
          final userSnapshot =
          await _usersRef.child(messageData['userKey']).get();
          final username = userSnapshot.child('username').value ?? 'Anonymous';

          // Apply bad word filtering
          final filteredMessage = _filterBadWords(messageData['message'] ?? '');

          messages.add({
            'userKey': messageData['userKey'],
            'username': username,
            'message': filteredMessage,
            'timestamp': messageData['timestamp'] ??
                DateTime.now().millisecondsSinceEpoch,
            'packageName': messageData['packageName'],
            'packageDetails': messageData['packageDetails'] != null
                ? List<Map<String, dynamic>>.from(
                (messageData['packageDetails'] as List)
                    .map((attr) => Map<String, dynamic>.from(attr)))
                : [],
          });
        } catch (e) {
          print("Error parsing message: $e");
        }
      }

      messages.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    });
  }

  Future<void> _postMessage() async {
    if (_messageController.text.isEmpty) return;

    // Apply bad word filtering before posting
    final filteredMessage = _filterBadWords(_messageController.text);

    final newMessageRef = _communityRef.push();
    await newMessageRef.set({
      'userKey': widget.userKey,
      'message': filteredMessage,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    _messageController.clear();
  }

  String _filterBadWords(String message) {
    final List<String> badWords = [
      "anal",
      "anus",
      "arse",
      "ass",
      "ballsack",
      "balls",
      "bastard",
      "bitch",
      "biatch",
      "bloody",
      "blowjob",
      "blow job",
      "bollock",
      "bollok",
      "boner",
      "boob",
      "bugger",
      "bum",
      "butt",
      "buttplug",
      "clitoris",
      "cock",
      "coon",
      "crap",
      "cunt",
      "damn",
      "dick",
      "dildo",
      "dyke",
      "fag",
      "feck",
      "fellate",
      "fellatio",
      "felching",
      "fuck",
      "f u c k",
      "fudgepacker",
      "fudge packer",
      "flange",
      "Goddamn",
      "God damn",
      "hell",
      "homo",
      "jerk",
      "jizz",
      "knobend",
      "knob end",
      "labia",
      "lmao",
      "lmfao",
      "muff",
      "nigger",
      "nigga",
      "omg",
      "penis",
      "piss",
      "poop",
      "prick",
      "pube",
      "pussy",
      "queer",
      "scrotum",
      "sex",
      "shit",
      "s hit",
      "sh1t",
      "slut",
      "smegma",
      "spunk",
      "tit",
      "tosser",
      "turd",
      "twat",
      "vagina",
      "wank",
      "whore",
      "wtf"
    ];

    String filteredMessage = message;

    for (String badWord in badWords) {
      final regex = RegExp(r'\b' + RegExp.escape(badWord) + r'\b',
          caseSensitive: false);
      filteredMessage = filteredMessage.replaceAll(regex, '****');
    }

    return filteredMessage;
  }

  void _navigateToMap(List<Map<String, dynamic>> attractions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserGoogleMapPageCustom(attractions: attractions),
      ),
    );
  }

  void _showPackageDetails(Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final List<Map<String, dynamic>> packageDetails =
        List<Map<String, dynamic>>.from(message['packageDetails']);
        final startPoint =
        packageDetails.isNotEmpty ? packageDetails.first : null;
        final endPoint =
        packageDetails.isNotEmpty ? packageDetails.last : null;

        return AlertDialog(
          title: Text(message['packageName'] ?? 'Package Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Attractions in this package:'),
              if (startPoint != null)
                ListTile(
                  title: Text(startPoint['siteName'] ?? 'Unknown Site'),
                  leading: Image.network(
                    startPoint['siteImage'] ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  subtitle: const Text('Start Point',
                      style: TextStyle(color: Colors.green)),
                ),
              ...List<Widget>.from(
                packageDetails.skip(1).take(packageDetails.length - 2).map(
                      (attraction) => ListTile(
                    title: Text(attraction['siteName'] ?? 'Unknown Site'),
                    leading: Image.network(
                      attraction['siteImage'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              if (endPoint != null && endPoint != startPoint)
                ListTile(
                  title: Text(endPoint['siteName'] ?? 'Unknown Site'),
                  leading: Image.network(
                    endPoint['siteImage'] ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  subtitle: const Text('End Point',
                      style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('View on Map'),
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToMap(packageDetails);
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(10),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Enter your message...',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.message, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: _postMessage,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? const Center(child: Text('No messages yet.'))
                : ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isPackageShared =
                    message['packageName'] != null;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  message['username'][0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['username'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _formatTimestamp(
                                        message['timestamp']),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (isPackageShared)
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shared Package: ${message['packageName']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.info_outline),
                                  label: const Text('View Details'),
                                  onPressed: () =>
                                      _showPackageDetails(message),
                                ),
                              ],
                            ),
                          if (!isPackageShared)
                            Text(
                              message['message'],
                              style: const TextStyle(fontSize: 15),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  String _formatTimestamp(int timestamp) {
    final dateTime =
    DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }
}
