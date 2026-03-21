import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Test Supabase connection screen
/// Navigate to this screen by adding: /test-connection route
class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  String _status = 'Not tested';
  String _details = '';
  bool _isTesting = false;

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _status = 'Testing...';
      _details = '';
    });

    try {
      // Test 1: Check if Supabase is initialized
      final client = Supabase.instance.client;
      final authResponse = client.auth.currentSession;
      
      // Test 2: Try to query the alumni table
      final response = await client.from('alumni').select().limit(1);
      
      setState(() {
        _status = '✅ Success!';
        _details = '''
Supabase Connected!

URL: ${client.rest.url}
Alumni table: Found (${response.length} rows returned)
Auth session: ${authResponse != null ? 'Active' : 'None'}

You can now use the app normally.
''';
        _isTesting = false;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _status = '❌ Database Error';
        _details = '''
Table 'alumni' not found or no permission.

Error: ${e.message}
Details: ${e.details}

Solution:
1. Go to SQL Editor in Supabase
2. Run the CREATE TABLE script
3. Restart the app
''';
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Connection Failed';
        _details = '''
Error: $e

Possible causes:
1. Invalid SUPABASE_URL in .env
2. Invalid SUPABASE_ANON_KEY in .env
3. No internet connection
4. Supabase project not set up

Check your .env file and try again.
''';
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Supabase Connection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 32),
            
            // Status Icon
            Icon(
              _status.contains('✅') 
                ? Icons.check_circle 
                : _status.contains('❌') 
                  ? Icons.error 
                  : Icons.help_outline,
              size: 80,
              color: _status.contains('✅') 
                ? Colors.green 
                : _status.contains('❌') 
                  ? Colors.red 
                  : Colors.grey,
            ),
            
            const SizedBox(height: 24),
            
            // Status Text
            Text(
              _status,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _status.contains('✅') 
                  ? Colors.green 
                  : _status.contains('❌') 
                    ? Colors.red 
                    : null,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Test Button
            ElevatedButton.icon(
              onPressed: _isTesting ? null : _testConnection,
              icon: _isTesting 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
              label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
            ),
            
            const SizedBox(height: 32),
            
            // Details
            if (_details.isNotEmpty)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _status.contains('✅') 
                      ? Colors.green.withOpacity(0.1)
                      : _status.contains('❌') 
                        ? Colors.red.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _details,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Quick Actions
            if (_status.contains('❌') && _details.contains('Table'))
              Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Open Supabase SQL Editor
                      launchUrl('https://app.supabase.com/project/mefthrvjlcwsoflvwuvj/sql/new');
                    },
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Open SQL Editor'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click to open Supabase and run the CREATE TABLE script',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void launchUrl(String url) {
    // Simple placeholder - in real app use url_launcher package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: $url'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
