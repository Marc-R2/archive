import 'package:archive/src/util/byte_shift.dart';

enum ByteOrder {
  littleEndian(ByteShiftLittleEndian()),
  bigEndian(ByteShiftBigEndian()),;

  const ByteOrder(this.shift);

  final ByteShift shift;
}
