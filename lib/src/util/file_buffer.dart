import 'dart:math';
import 'dart:typed_data';

import 'abstract_file_handle.dart';
import 'byte_order.dart';
import 'byte_shift.dart';

/// Buffered file reader reduces file system disk access by reading in
/// buffers of the file so that individual file reads
/// can be read from the cached buffer.
class FileBuffer {
  final AbstractFileHandle file;
  final ByteShift byteShift;
  late Uint8List _buffer;
  int _fileSize = 0;
  int _position = 0;
  int _bufferSize = 0;

  /// The buffer size should be at least 8 bytes, so reading a 64-bit value
  /// doesn't have to deal with buffer overflow.
  static const kMinBufferSize = 8;
  static const kDefaultBufferSize = 1024;

  /// Create a FileBuffer with the given [file].
  /// [byteOrder] determines if multi-byte values should be read in bigEndian
  /// or littleEndian order.
  /// [bufferSize] controls the size of the buffer to use for file IO caching.
  /// The larger the buffer, the less it will have to access the file system.
  FileBuffer(
    this.file, {
    ByteOrder byteOrder = ByteOrder.littleEndian,
    int bufferSize = kDefaultBufferSize,
  }) : byteShift = byteOrder.shift {
    if (!file.isOpen) {
      file.open();
    }
    _fileSize = file.length;
    // Prevent having a buffer smaller than the minimum buffer size
    _bufferSize = max(
      // If possible, avoid having a buffer bigger than the file itself
      min(bufferSize, _fileSize),
      kMinBufferSize,
    );
    _buffer = Uint8List(_bufferSize);
    _readBuffer(0, _fileSize);
  }

  FileBuffer.from(FileBuffer other, {int? bufferSize})
      : this.byteShift = other.byteShift,
        this.file = other.file {
    this._bufferSize = bufferSize ?? other._bufferSize;
    this._position = other._position;
    this._fileSize = other._fileSize;
    _buffer = Uint8List(_bufferSize);
  }

  /// The length of the file in bytes.
  int get length => _fileSize;

  /// True if the file is currently open.
  bool get isOpen => file.isOpen;

  /// Open the file synchronously for reading.
  bool open() => file.open();

  /// Close the file asynchronously.
  Future<void> close() async {
    await file.close();
    _fileSize = 0;
    _position = 0;
  }

  /// Close the file synchronously.
  void closeSync() {
    file.closeSync();
    _fileSize = 0;
    _position = 0;
  }

  /// Reset the read position of the file back to 0.
  void reset() {
    _position = 0;
  }

  /// Read an 8-bit unsigned int at the given [position] within the file.
  /// [fileSize] is used to ensure bytes aren't read past the end of
  /// an [InputFileStream].
  int readUint8(int position, [int? fileSize]) {
    if (position >= _fileSize || position < 0) {
      return 0;
    }
    if (position < _position || position >= (_position + _bufferSize)) {
      _readBuffer(position, fileSize ?? _fileSize);
    }
    final p = position - _position;
    return _buffer[p];
  }

  /// Read a 16-bit unsigned int at the given [position] within the file.
  int readUint16(int position, [int? fileSize]) {
    if (position >= (_fileSize - 2) || position < 0) {
      return 0;
    }
    if (position < _position || position >= (_position + (_bufferSize - 2))) {
      _readBuffer(position, fileSize ?? _fileSize);
    }
    var p = position - _position;
    return byteShift.uint16(_buffer, p);
  }

  /// Read a 24-bit unsigned int at the given [position] within the file.
  int readUint24(int position, [int? fileSize]) {
    if (position >= (_fileSize - 3) || position < 0) {
      return 0;
    }
    if (position < _position || position >= (_position + (_bufferSize - 3))) {
      _readBuffer(position, fileSize ?? _fileSize);
    }
    var p = position - _position;
    return byteShift.uint24(_buffer, p);
  }

  /// Read a 32-bit unsigned int at the given [position] within the file.
  int readUint32(int position, [int? fileSize]) {
    if (position >= (_fileSize - 4) || position < 0) {
      return 0;
    }
    if (position < _position || position >= (_position + (_bufferSize - 4))) {
      _readBuffer(position, fileSize ?? _fileSize);
    }
    var p = position - _position;
    return byteShift.uint32(_buffer, p);
  }

  /// Read a 64-bit unsigned int at the given [position] within the file.
  int readUint64(int position, [int? fileSize]) {
    if (position >= (_fileSize - 8) || position < 0) {
      return 0;
    }
    if (position < _position || position >= (_position + (_bufferSize - 8))) {
      _readBuffer(position, fileSize ?? _fileSize);
    }
    var p = position - _position;
    return byteShift.uint64(_buffer, p);
  }

  /// Read [count] bytes starting at the given [position] within the file.
  Uint8List readBytes(int position, int count, [int? fileSize]) {
    if (count > _buffer.length) {
      if (position + count >= _fileSize) {
        count = _fileSize - position;
      }
      final bytes = Uint8List(count);
      file.position = position;
      file.readInto(bytes);
      return bytes;
    }

    if (position < _position ||
        (position + count) >= (_position + _bufferSize)) {
      _readBuffer(position, fileSize ?? _fileSize);
    }

    final start = position - _position;
    final bytes = _buffer.sublist(start, start + count);
    return bytes;
  }

  void _readBuffer(int position, int fileSize) {
    file.position = position;
    final size = min(fileSize, _buffer.length);
    _bufferSize = file.readInto(_buffer, size);
    _position = position;
  }
}
