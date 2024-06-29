import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Click Counter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<Map<String, dynamic>> _counters = [];

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshCounters();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _refreshCounters() async {
    final data = await DatabaseHelper.instance.readAllCounters();
    print('Read counters: $data');
    setState(() {
      _counters = data;
    });
  }

  Future<void> _saveCounter() async {
    if (_nameController.text.isNotEmpty) {
      print('Saving counter: ${_nameController.text}, count: $_counter');
      await DatabaseHelper.instance
          .createCounter(_nameController.text, _counter);
      _nameController.clear();
      setState(() {
        _counter = 0;
        // After saving, refresh counters
        _refreshCounters();
      });
    }
  }

  Future<void> _deleteCounter(int id) async {
    print('Deleting counter with id: $id');
    await DatabaseHelper.instance.deleteCounter(id);
    _refreshCounters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Click Counter App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have clicked the button this many times:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              '$_counter',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _incrementCounter,
              child: Text(
                'Click me!',
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _nameController,
                decoration:
                    InputDecoration(labelText: 'Enter name for the counter'),
              ),
            ),
            ElevatedButton(
              onPressed: _saveCounter,
              child: Text('Save Counter'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _counters.isEmpty
                  ? Center(
                      child: Text('Thank you for using this click counters'))
                  : ListView.builder(
                      itemCount: _counters.length,
                      itemBuilder: (context, index) {
                        final counter = _counters[index];
                        return ListTile(
                          title: Text(counter['name']),
                          subtitle: Text('Count: ${counter['count']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteCounter(counter['id']),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
