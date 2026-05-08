import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:reactive_state/reactive_state.dart';

class SecondCounterPage extends StatefulWidget {
  const SecondCounterPage({super.key});

  @override
  State<SecondCounterPage> createState() => _SecondCounterPageState();
}

class _SecondCounterPageState extends State<SecondCounterPage> {
  final CounterController _controller = CounterController.instance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text('Second Counter Page'),
      ),
      body: Watch(
        builder: () {
          return Center(
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Text(
                  '${_controller.count}',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 60),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.decrement,
        tooltip: 'Decrement',
        child: const Icon(Icons.remove),
      ),
    );
  }
}
