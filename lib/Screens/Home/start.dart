import 'package:flutter/material.dart';

import 'home.dart';



class PodlyApp extends StatefulWidget {
  const PodlyApp({super.key, required this.title});

  final String title;

  @override
  PodlyHome createState() => PodlyHome();
}

class PodlyHome extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [SizedBox(
            width: double.infinity,
            height: 300,
            child: Image.asset(
              'assets/podly.png', // path to your image
              fit: BoxFit.cover,
            ),
          ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Podly',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start your day with personalized podcasts',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      child:
                      Image.asset(
                        'assets/asimg/bt1.png', // path to your image
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      child:
                      Image.asset(
                        'assets/asimg/bt2.png', // path to your image
                        fit: BoxFit.cover,
                      ),
                    ),Container(
                      padding: const EdgeInsets.all(4.0),
                      child:
                      Image.asset(
                        'assets/asimg/bt3.png', // path to your image
                        fit: BoxFit.cover,
                      ),
                    ),Container(
                      padding: const EdgeInsets.all(4.0),
                      child:
                      Image.asset(
                        'assets/asimg/bt4.png', // path to your image
                        fit: BoxFit.cover,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 36.0, top: 16, left: 36, right: 16),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const MyHomePage(title: 'Flutter Demo Home Page')
                          ),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}