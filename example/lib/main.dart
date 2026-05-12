import 'package:example/pages/heavy_isolate_example_page.dart';
import 'package:example/pages/logger_example_page.dart';
import 'package:example/pages/pagination_list_view_page.dart';
import 'package:example/pages/search_page.dart';
import 'package:example/pages/second_counter_page.dart';
import 'package:flutter/material.dart';
import 'package:reactive_flutter/reactive_flutter.dart';

final ReactiveLogger logger = ReactiveLogger(
  fileName: 'example',
  clearPolicy: ClearPolicy.daily,
  minLevel: LogLevel.debug,
  printToConsole: true,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  CounterController.register();

  await logger.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reactive State Example',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.deepPurple,
          selectionColor: Colors.deepPurple.withValues(alpha: 0.3),
          selectionHandleColor: Colors.deepPurple,
        ),
      ),
      home: const MyHomePage(title: 'Reactive State Example'),

      // builder: (context, child) {
      //   return LoggerOverlay(logger: logger, child: child ?? SizedBox.shrink());
      // },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CounterController _controller = CounterController.instance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Watch(
        builder: () {
          return Center(
            child: Column(
              mainAxisAlignment: .center,
              children: [
                const Text('You have pushed the button this many times:'),
                Text(
                  '${_controller.count}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SecondCounterPage(),
                      ),
                    );
                  },
                  child: Text('Second Page'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaginationListViewPage(),
                      ),
                    );
                  },
                  child: Text('Reactive Pagination'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                  child: Text('Reactive Search'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoggerExamplePage(),
                      ),
                    );
                  },
                  child: Text('Reactive Logger'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HeavyIsolateExamplePage(),
                      ),
                    );
                  },
                  child: Text('Reactive Isolate'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CounterController {
  static CounterController instance() {
    return ReactiveInjector.find<CounterController>();
  }

  static void register() {
    ReactiveInjector.singleton(() => CounterController());
  }

  final Reactive<int> _counter = Reactive<int>(0);

  void increment() {
    _counter.value++;
  }

  void decrement() {
    _counter.value--;
  }

  int get count => _counter.value;
}
