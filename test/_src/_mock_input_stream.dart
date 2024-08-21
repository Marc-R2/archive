import 'package:archive/archive.dart';
import 'package:test/expect.dart';

class MockInputStream extends InputMemoryStream {
  MockInputStream(super.bytes, {super.byteOrder, super.offset, super.length});

  @override
  MockInputStream subset({int? position, int? length, int? bufferSize}) {
    return MockInputStream(
      buffer,
      byteOrder: byteOrder,
      offset: position,
      length: length,
    );
  }

  int readByteCalls = 0;

  void expectReadByteCalls(dynamic expected) {
    expect(
      readByteCalls,
      expected,
      reason: 'unexpected number of InputStream.readByte calls',
    );
  }

  @override
  int readByte() {
    readByteCalls++;
    return super.readByte();
  }
}
