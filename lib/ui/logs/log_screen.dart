import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getaqi/Services/aqi_log_service.dart';

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});

  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Refresh logs whenever screen is opened
    Future.microtask(() {
      ref.invalidate(aqiReadprovider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(aqiReadprovider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("AQI Logs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ref.refresh(aqiReadprovider.future);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: logsAsync.when(
                  error: (e, st) => Text(e.toString()),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  data: (data) => SingleChildScrollView(
                    child: Text(
                      data.isEmpty ? "No logs available." : data,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () async {
                  final path = await LogService.exportLogs();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Exported to $path')),
                    );
                  }
                },
                child: const Text("Export Logs"),
              ),

              ElevatedButton(
                onPressed: () async {
                  await LogService.shareLogs();
                },
                child: const Text("Share Logs"),
              ),

              ElevatedButton(
                onPressed: () async {
                  await LogService.deleteLogs();

                  // IMPORTANT: Refresh read provider
                  ref.invalidate(aqiReadprovider);
                },
                child: const Text("Delete Logs"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
