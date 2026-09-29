import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'features/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  if (url.isEmpty || key.isEmpty) {
    runApp(const ConfigMissingApp());
    return;
  }
  await Supabase.initialize(url: url, publishableKey: key);
  runApp(const MovbotApp());
}

class ConfigMissingApp extends StatelessWidget {
  const ConfigMissingApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(
          body: Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Configure SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY before running Movbot.'))),
        ),
      );
}
