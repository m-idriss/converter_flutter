import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Chat',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your conversations will appear here',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
