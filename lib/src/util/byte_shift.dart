import 'dart:typed_data';

import 'byte_order.dart';

abstract class ByteShift {
  const ByteShift._();

  ByteOrder get byteOrder;

  int uint16(Uint8List bytes, int offset);

  int uint24(Uint8List bytes, int offset);

  int uint32(Uint8List bytes, int offset);

  int uint64(Uint8List bytes, int offset);
}

class ByteShiftBigEndian extends ByteShift {
  const ByteShiftBigEndian() : super._();

  @override
  ByteOrder get byteOrder => ByteOrder.bigEndian;

  @override
  int uint16(Uint8List bytes, int offset) {
    return (bytes[0 + offset] << 8) | bytes[1 + offset];
  }

  @override
  int uint24(Uint8List bytes, int offset) {
    return (bytes[0 + offset] << 16) |
        (bytes[1 + offset] << 8) |
        bytes[2 + offset];
  }

  @override
  int uint32(Uint8List bytes, int offset) {
    return (bytes[0 + offset] << 24) |
        (bytes[1 + offset] << 16) |
        (bytes[2 + offset] << 8) |
        bytes[3 + offset];
  }

  @override
  int uint64(Uint8List bytes, int offset) {
    return (bytes[0] << 56) |
        (bytes[1 + offset] << 48) |
        (bytes[2 + offset] << 40) |
        (bytes[3 + offset] << 32) |
        (bytes[4 + offset] << 24) |
        (bytes[5 + offset] << 16) |
        (bytes[6 + offset] << 8) |
        bytes[7 + offset];
  }
}

class ByteShiftLittleEndian extends ByteShift {
  const ByteShiftLittleEndian() : super._();

  @override
  ByteOrder get byteOrder => ByteOrder.littleEndian;

  @override
  int uint16(Uint8List bytes, int offset) {
    return (bytes[1 + offset] << 8) | bytes[0 + offset];
  }

  @override
  int uint24(Uint8List bytes, int offset) {
    return (bytes[2 + offset] << 16) |
        (bytes[1 + offset] << 8) |
        bytes[0 + offset];
  }

  @override
  int uint32(Uint8List bytes, int offset) {
    return (bytes[3 + offset] << 24) |
        (bytes[2 + offset] << 16) |
        (bytes[1 + offset] << 8) |
        bytes[0 + offset];
  }

  @override
  int uint64(Uint8List bytes, int offset) {
    return (bytes[7 + offset] << 56) |
        (bytes[6 + offset] << 48) |
        (bytes[5 + offset] << 40) |
        (bytes[4 + offset] << 32) |
        (bytes[3 + offset] << 24) |
        (bytes[2 + offset] << 16) |
        (bytes[1 + offset] << 8) |
        bytes[0 + offset];
  }
}
