import 'package:flutter/widgets.dart';
import 'package:trivia/l10n/generated/app_localizations.dart';

export 'package:trivia/l10n/generated/app_localizations.dart';

/// `context.l10n.someString` instead of `AppLocalizations.of(context).someString`.
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
