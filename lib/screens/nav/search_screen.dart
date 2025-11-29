import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

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
                Icons.search,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Search',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Search for courses and content',
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
