import 'package:flutter/material.dart';
import '../services/calendly_service.dart';

class CalendlyLogsScreen extends StatefulWidget {
  const CalendlyLogsScreen({super.key});

  @override
  State<CalendlyLogsScreen> createState() => _CalendlyLogsScreenState();
}

class _CalendlyLogsScreenState extends State<CalendlyLogsScreen> {
  final _calendlyService = CalendlyService.instance;
  List<CalendlyLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    
    final logs = await _calendlyService.getLogs(take: 50);
    
    if (mounted) {
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendly Webhooks'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E3F),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay webhooks registrados',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Los eventos de Calendly aparecerán aquí',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLogs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return _buildLogCard(log);
                    },
                  ),
                ),
    );
  }

  Widget _buildLogCard(CalendlyLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E3F).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.webhook,
            color: Color(0xFF1B5E3F),
          ),
        ),
        title: Text(
          log.eventType ?? 'Sin tipo de evento',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  log.formattedDate,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (log.preview.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                log.preview,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Chip(
          label: Text(
            'ID: ${log.id}',
            style: const TextStyle(fontSize: 11),
          ),
          backgroundColor: const Color(0xFFF1F8F3),
        ),
      ),
    );
  }
}
