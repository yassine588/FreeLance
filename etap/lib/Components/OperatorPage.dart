import 'package:flutter/material.dart';
import 'AddAssignmentPage.dart';

class OperatorPage extends StatefulWidget {
  const OperatorPage({Key? key}) : super(key: key);

  @override
  State<OperatorPage> createState() => _OperatorPageState();
}

class _OperatorPageState extends State<OperatorPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Operations Management'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.assignment), text: 'Assignments'),
              Tab(icon: Icon(Icons.schedule), text: 'Schedule'),
              Tab(icon: Icon(Icons.history), text: 'History'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AssignmentsTab(),
            ScheduleTab(),
            HistoryTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAssignmentPage()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class AssignmentsTab extends StatelessWidget {
  const AssignmentsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.assignment, color: Colors.blue),
          title: Text('Delivery to Sousse'),
          subtitle: Text('Driver: Ahmed - Vehicle: Toyota Hilux - Status: In Progress'),
        ),
        ListTile(
          leading: Icon(Icons.assignment, color: Colors.green),
          title: Text('Client pickup from airport'),
          subtitle: Text('Driver: Mohamed - Vehicle: Mercedes - Status: Scheduled'),
        ),
        ListTile(
          leading: Icon(Icons.assignment, color: Colors.orange),
          title: Text('Equipment transport'),
          subtitle: Text('Driver: Ali - Vehicle: Renault Kangoo - Status: Pending'),
        ),
      ],
    );
  }
}

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Schedule View - Coming Soon'),
    );
  }
}

class HistoryTab extends StatelessWidget {
  const HistoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.history, color: Colors.grey),
          title: Text('Completed: Delivery to Tunis'),
          subtitle: Text('Driver: Sami - Vehicle: Toyota Hilux - Date: 10/05/2023'),
        ),
        ListTile(
          leading: Icon(Icons.history, color: Colors.grey),
          title: Text('Completed: Client meeting transport'),
          subtitle: Text('Driver: Karim - Vehicle: Mercedes - Date: 09/05/2023'),
        ),
      ],
    );
  }
}
