import 'package:flutter/material.dart';

import '../state/demo_scope.dart';
import '../state/event_log.dart';

/// Opens the event log, which lists what the demo's buttons did.
void showEventLog(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _EventLogSheet(log: DemoScope.read(context).log),
  );
}

/// An app bar button that opens the event log.
class EventLogButton extends StatelessWidget {
  const EventLogButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => showEventLog(context),
      tooltip: 'Event log',
      icon: const Icon(Icons.receipt_long),
    );
  }
}

class _EventLogSheet extends StatelessWidget {
  const _EventLogSheet({required this.log});

  final EventLog log;

  String _time(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: ListenableBuilder(
        listenable: log,
        builder: (context, _) {
          final entries = log.entries;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Event log',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: entries.isEmpty ? null : log.clear,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: entries.isEmpty
                    ? const Center(child: Text('Nothing has happened yet.'))
                    : ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return ListTile(
                            dense: true,
                            title: Text(entry.message),
                            subtitle: Text(_time(entry.time)),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
