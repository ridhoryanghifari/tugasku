export 'db_init_stub.dart'
    if (dart.library.ffi) 'db_init_ffi.dart'
    if (dart.library.js_interop) 'db_init_web.dart';