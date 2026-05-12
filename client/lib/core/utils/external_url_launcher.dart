import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

typedef ExternalUrlLauncher = Future<bool> Function(Uri uri, {LaunchMode mode});

Future<bool> defaultExternalUrlLauncher(
  Uri uri, {
  LaunchMode mode = LaunchMode.externalApplication,
}) {
  return launchUrl(uri, mode: mode);
}

Future<void> launchExternalUrl(
  BuildContext context, {
  required String url,
  required String errorMessage,
  ExternalUrlLauncher launcher = defaultExternalUrlLauncher,
}) async {
  final uri = Uri.tryParse(url);
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https') || uri.host.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
    return;
  }

  try {
    final launched = await launcher(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }
}
