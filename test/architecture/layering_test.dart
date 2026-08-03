import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Architecture rules that a code review will eventually miss.
///
/// These are cheap, they run on every PR, and they are the difference
/// between a layered architecture and a diagram of one.
void main() {
  final lib = Directory('lib');

  Iterable<File> dartFilesUnder(String path) {
    final dir = Directory(path);
    if (!dir.existsSync()) return const [];
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.endsWith('.g.dart'))
        .where((f) => !f.path.endsWith('.freezed.dart'));
  }

  test('domain layers import neither Flutter nor Riverpod', () {
    final offenders = <String>[];

    for (final file in dartFilesUnder('lib/features')) {
      if (!file.path.contains('/domain/')) continue;
      final source = file.readAsStringSync();
      final bad = [
        'package:flutter/',
        'package:riverpod',
        'package:flutter_riverpod',
        'package:drift/',
        'package:dio/',
      ].where(source.contains);
      if (bad.isNotEmpty) offenders.add('${file.path}: ${bad.join(', ')}');
    }

    // A domain folder must compile as plain Dart. If it cannot, the business
    // rules are entangled with the framework and cannot be tested cheaply.
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('no feature imports another feature', () {
    final offenders = <String>[];

    for (final file in dartFilesUnder('lib/features')) {
      final segments = file.path.split(Platform.pathSeparator);
      final i = segments.indexOf('features');
      if (i == -1 || i + 1 >= segments.length) continue;
      final own = segments[i + 1];

      for (final line in file.readAsLinesSync()) {
        if (!line.startsWith('import ')) continue;
        final match =
            RegExp(r'package:quran_one/features/([a-z_]+)/').firstMatch(line);
        final other = match?.group(1);
        if (other != null && other != own) {
          offenders.add('${file.path} -> $other');
        }
      }
    }

    // Cross-feature needs go through an interface in shared/domain, bound in
    // app/di.dart. Otherwise the dependency graph becomes a mesh by M4.
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('no provider returns a concrete Impl type', () {
    final offenders = <String>[];

    for (final file in dartFilesUnder('lib')) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (!lines[i].contains('@Riverpod') && !lines[i].contains('@riverpod')) {
          continue;
        }
        final next = i + 1 < lines.length ? lines[i + 1] : '';
        if (RegExp(r'^[A-Za-z<>, ]*Impl[ <]').hasMatch(next)) {
          offenders.add('${file.path}:${i + 2} $next');
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('lib/ has exactly the five permitted top-level directories', () {
    final dirs = lib
        .listSync()
        .whereType<Directory>()
        .map((d) => d.path.split(Platform.pathSeparator).last)
        .toSet();

    expect(
      dirs.difference({'app', 'core', 'shared', 'features', 'l10n',
          'presentation'}),
      isEmpty,
    );
  });
}
