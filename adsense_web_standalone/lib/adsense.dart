library adsense_web_standalone;

export 'src/adsense_stub.dart' // Stub implementation
// if (dart.library.io) 'src/hw_io.dart' // dart:io implementation
    if (dart.library.js_interop) 'src/adsense.dart'; // package:web implementation
