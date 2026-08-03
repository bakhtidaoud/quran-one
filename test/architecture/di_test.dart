import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_one/app/di.dart';

import '../helpers/container.dart';

void main() {
  group('composition root', () {
    test('every root dependency resolves', () {
      final container = makeContainer();

      // The cheapest possible integration test. If a provider is missing an
      // override, has a cyclic dependency, or throws while constructing,
      // this fails in milliseconds instead of on a user's cold start.
      for (final dependency in rootDependencies) {
        expect(
          () => container.read(dependency),
          returnsNormally,
          reason: 'failed to resolve $dependency',
        );
      }
    });

    test('repositories are singletons within a container', () {
      final container = makeContainer();

      expect(
        identical(
          container.read(ayahRepositoryProvider),
          container.read(ayahRepositoryProvider),
        ),
        isTrue,
        reason: 'keepAlive repositories must not be rebuilt per read',
      );
    });

    test('use cases are disposed when nothing listens', () {
      final container = makeContainer();

      final first = container.read(getAnnotatedRangeProvider);
      // autoDispose: no listener survives the read, so the next read must
      // produce a fresh instance. If this ever returns the same object, the
      // provider has silently become keepAlive.
      final second = container.read(getAnnotatedRangeProvider);

      expect(identical(first, second), isFalse);
    });
  });

  group('binding rules', () {
    test('di.dart is the only file that names an Impl type', () {
      final offenders = <String>[];

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.path.endsWith('di.dart')) continue;
        if (entity.path.contains('/data/')) continue;
        if (entity.path.endsWith('.g.dart')) continue;

        final source = entity.readAsStringSync();
        // A presentation or domain file that mentions a concrete
        // implementation has bypassed the composition root, which means the
        // interface is decorative.
        if (RegExp(r'\b\w+Impl\b').hasMatch(source)) {
          offenders.add(entity.path);
        }
      }

      expect(offenders, isEmpty);
    });

    test('no provider outside di.dart declares a keepAlive repository', () {
      final offenders = <String>[];

      for (final entity in Directory('lib/features').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.path.endsWith('.g.dart')) continue;

        final source = entity.readAsStringSync();
        if (source.contains('keepAlive: true') &&
            source.contains('Repository ')) {
          offenders.add(entity.path);
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'repository bindings belong in app/di.dart',
      );
    });
  });
}
