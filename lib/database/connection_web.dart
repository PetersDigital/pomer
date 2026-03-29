import 'dart:developer' as developer;
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

DatabaseConnection openConnection() {
  return DatabaseConnection.delayed(
    Future(
      () async {
        try {
          // In a production Web deployment with WASM, the base-href can shift the relative
          // paths, so we ensure the URI resolves against the current document base URL.
          final sqlite3Uri = Uri.base.resolve('sqlite3.wasm');
          final driftWorkerUri = Uri.base.resolve('drift_worker.js');
          final result = await WasmDatabase.open(
            databaseName: 'pomer_db',
            sqlite3Uri: sqlite3Uri,
            driftWorkerUri: driftWorkerUri,
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
          // Re-throwing the exception to allow the UI to handle the error state.
          rethrow;
        }
      },
    ),
  );
}
