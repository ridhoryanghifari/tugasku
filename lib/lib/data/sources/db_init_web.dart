import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
    show databaseFactoryFfiWebNoWebWorker;

/// Web: SQLite berjalan lewat WebAssembly (data disimpan di IndexedDB browser).
void initDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}