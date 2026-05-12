import 'package:flutter/material.dart';
import 'package:reactive_flutter/reactive_flutter.dart';

class HeavyIsolateExamplePage extends StatefulWidget {
  const HeavyIsolateExamplePage({super.key});

  @override
  State<HeavyIsolateExamplePage> createState() =>
      _HeavyIsolateExamplePageState();
}

class _HeavyIsolateExamplePageState extends State<HeavyIsolateExamplePage> {
  final ReactiveIsolateTask<int> task = ReactiveIsolateTask<int>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reactive Isolate Example')),
      body: Center(
        child: Watch(
          builder: () {
            if (task.isLoading) {
              return const CircularProgressIndicator();
            }

            if (task.error != null) {
              return Text(task.error.toString());
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Result: ${task.data ?? 0}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await task.run<int>(
                      ReactiveTaskPayload(
                        input: 100000,
                        callback: (int totalNumbers) {
                          int sum = 0;

                          for (int i = 0; i < totalNumbers; i++) {
                            sum += i;
                          }

                          return sum;
                        },
                      ),
                    );
                  },
                  child: const Text('Run Heavy Task'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
