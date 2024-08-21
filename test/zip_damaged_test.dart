import 'dart:math';
import 'package:archive/archive_io.dart';
import 'package:test/test.dart';

import '_src/_mock_input_stream.dart';

void main() async {
  group('damaged zip', () {
    test('8kb 8/1 damaged archive', () {
      final (encoded, damaged) = createArchive(size: 8192);
      final (decoded, decodedDamaged) = decodeArchive((encoded, damaged));

      expect(decoded.length, equals(1));
      expect(decodedDamaged.length, equals(0));

      encoded.expectReadByteCalls(equals(4080));
      damaged.expectReadByteCalls(equals(36864));
    });

    test('128kb 8/16 damaged archive', () {
      final (encoded, damaged) = createArchive(size: 8192, numFiles: 16);
      final (decoded, decodedDamaged) = decodeArchive((encoded, damaged));

      expect(decoded.length, equals(16));
      expect(decodedDamaged.length, equals(0));

      encoded.expectReadByteCalls(equals(4530));
      damaged.expectReadByteCalls(equals(532480));
    });

    test('1mb 1/128 damaged archive', () {
      final (encoded, damaged) = createArchive(size: 8192, numFiles: 128);
      final (decoded, decodedDamaged) = decodeArchive((encoded, damaged));

      expect(decoded.length, equals(128));
      expect(decodedDamaged.length, equals(0));

      encoded.expectReadByteCalls(equals(7890));
      damaged.expectReadByteCalls(equals(4247552));
    });

    test('8mb 1/1024 damaged archive', () {
      final (encoded, damaged) = createArchive(size: 8192 * 2, numFiles: 512);
      final (decoded, decodedDamaged) = decodeArchive((encoded, damaged));

      expect(decoded.length, equals(512));
      expect(decodedDamaged.length, equals(0));

      encoded.expectReadByteCalls(equals(19410));
      damaged.expectReadByteCalls(equals(33771520));
    });
  });
}

(Archive, Archive) decodeArchive((MockInputStream, MockInputStream) streams) {
  final decoded = ZipDecoder().decodeStream(streams.$1);
  final decodedDamaged = ZipDecoder().decodeStream(streams.$2);
  return (decoded, decodedDamaged);
}

(MockInputStream, MockInputStream) createArchive({
  required int size,
  int seed = 0,
  int numFiles = 1,
  int damagedSize = 64,
}) {
  final archive = Archive();

  final rng = Random(ZipFileHeader.signature + seed);

  for (var i = 0; i < numFiles; i++) {
    final randomData = List<int>.generate(size, (_) => rng.nextInt(256));
    archive.addFile(ArchiveFile.bytes('test$i.txt', randomData));
  }

  final encoded = ZipEncoder().encode(archive);
  final encodedStream = MockInputStream(encoded);

  // [ZipFileHeader.signature] = 0x02014b50;
  const signature = <int>[0x50, 0x4b, 0x01, 0x02];
  expect(encoded, containsAllInOrder(signature));

  final damagedStream = encodedStream.subset(
    position: 0,
    length: encoded.length - damagedSize,
  );

  return (encodedStream, damagedStream);
}
