import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:transaction_screen/core/local_storage/locale_storage.dart';
import 'package:transaction_screen/core/localization/locale_state.dart';
import 'package:transaction_screen/core/localization/system_locale_provider.dart';

/// Owns the user's chosen locale.
///
/// `null` means "follow the device locale". Otherwise, the cubit emits
/// a normalized BCP-47 language tag for one of the [supportedTags].
@lazySingleton
class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit(this._storage, this._systemLocaleProvider) : super(const LocaleState());

  final LocaleStorage _storage;
  final ISystemLocaleProvider _systemLocaleProvider;

  static const supportedTags = <String>{'en', 'ru'};

  Future<void> load() async {
    final storedTag = await _storage.readLocaleTag();
    final normalizedStoredTag = _normalizeTag(storedTag);
    if (storedTag != null && normalizedStoredTag == null) {
      await _storage.writeLocaleTag(null);
    }
    emit(state.copyWith(localeTag: normalizedStoredTag));
  }

  Future<void> setLocale(Locale? locale) async {
    final tag = _normalizeTag(locale?.languageCode);
    await _storage.writeLocaleTag(tag);
    emit(state.copyWith(localeTag: tag));
  }

  Locale? get locale {
    final tag = state.localeTag;
    if (tag == null) return null;
    return Locale.fromSubtags(languageCode: tag);
  }

  String? _normalizeTag(String? tag) {
    final normalized = tag?.trim().toLowerCase();
    if (normalized == null) return null;
    return supportedTags.contains(normalized) ? normalized : null;
  }

  // Used to pick a fallback language when the stored tag is null —
  // e.g. for backend error translations that need a concrete language.
  String resolveEffectiveTag() {
    final stored = state.localeTag;
    if (stored != null) return stored;
    final system = _normalizeTag(_systemLocaleProvider.getCurrentLocale().languageCode);
    return system ?? 'en';
  }
}
