import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final qCtrl = TextEditingController();
  List results = [];
  String botReply = '';

  Future<void> doSearch() async {
    final q = qCtrl.text.trim();
    if (q.isEmpty) return;
    final res = await ApiService.search(q);
    setState(() { results = res; });
  }

  Future<void> doChat() async {
    final r = await ApiService.chatbot('Suggest me breakfast with high protein');
    setState(() { botReply = r; });
  }

  Future<void> doRecommend() async {
    final res = await ApiService.recommend([]);
    setState(() { results = res; });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService()._auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Food'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => AuthService().signOut()),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: qCtrl, decoration: const InputDecoration(hintText: 'Search dishes (e.g. "spicy noodle bowl")'), onSubmitted: (_) => doSearch()),
          const SizedBox(height: 8),
          Row(children: [
            ElevatedButton(onPressed: doSearch, child: const Text('Search')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: doRecommend, child: const Text('Recommend')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: doChat, child: const Text('Chatbot')),
          ]),
          if (botReply.isNotEmpty) Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(botReply))),
          const SizedBox(height: 12),
          Expanded(child: ListView.builder(itemCount: results.length, itemBuilder: (c,i){
            final it = results[i];
            final payload = it['payload'] ?? it;
            return ListTile(title: Text(payload['name'] ?? payload['title'] ?? 'No title'), subtitle: Text(payload['description'] ?? ''));
          })),
        ]),
      ),
    );
  }
}
