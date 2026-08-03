import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_one/app/router/routes.dart';
import 'package:quran_one/core/theme/theme_context.dart';

/// A 404 that offers a way forward.
///
/// A dead end here almost always means a link to an ayah reference that
/// does not exist. Saying "page not found" and stopping is accurate and
/// useless; suggesting the nearest valid destination is neither.
class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({required this.uri, this.error, super.key});

  const RouteErrorScreen.notFound({super.key})
      : uri = null,
        error = null;

  final Uri? uri;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'That reference does not exist',
                  style: context.text.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  uri == null
                      ? 'The link points somewhere the app cannot open.'
                      : 'Nothing here matches ${uri!.path}.',
                  style: context.text.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go(Routes.read),
                  child: const Text('Open the Quran index'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go(Routes.home),
                  child: const Text('Go home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
