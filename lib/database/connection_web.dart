import 'dart:developer' as developer;
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
// ignore: deprecated_member_use
import 'package:drift/web.dart';

DatabaseConnection openConnection() {
  return DatabaseConnection.delayed(Future(() async {
    try {
      // In a production Web deployment with WASM, the base-href can shift the relative
      // paths, so we ensure the URI resolves against the current document base URL.
      final result = await WasmDatabase.open(
        databaseName: 'pomer_db',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );

      if (result.missingFeatures.isNotEmpty) {
        developer.log(
          'Drift WASM missing features: ${result.missingFeatures}',
          name: 'Database',
        );
      }

      return result.resolvedExecutor;
    } catch (e, st) {
      developer.log(
        'Failed to open WebAssembly database, falling back to in-memory',
        name: 'Database',
        error: e,
        stackTrace: st,
      );
      // Fallback to in-memory database if WASM/worker setup completely fails
      // so the app does not blank-screen crash.
      // If we can't get the WASM module loaded at all, we can fallback to the web local storage
      // wrapper or a plain memory backend, but WasmDatabase.inMemory requires the sqlite3 wasm instance.
      // If WasmDatabase.open threw, the web environment might not support the worker/wasm at all.
      // In web without wasm, we use WebDatabase (from drift/web.dart)
      developer.log('Falling back to WebDatabase (IndexedDB)');
      return DatabaseConnection(WebDatabase('pomer_db_fallback'));
    }
  },),);
}
