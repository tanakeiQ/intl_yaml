/*
 * Copyright (c) 2018. tanakeiQ. All rights reserved.
 * License - MIT
 *
 * Author
 * - tanakeiQ<https://twitter.com/tanakeiQ>
 */

import 'stub.dart' as Stub;


String localeFile(String locale, List<String> methods) =>  """
// DO NOT EDIT. This is code generated via intlYaml
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

// ignore: unused_element
final _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => '$locale';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    ${methods.join(Stub.commaBreak)}
  };
}

""";


String allFile(String filePrefix, List<String> locales) =>  """
// DO NOT EDIT. This is code generated via intlYaml
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
// ignore: implementation_imports
import 'package:intl/src/intl_helpers.dart';

${locales.map((locale) => "import '${filePrefix}_$locale.dart' as messages_$locale;").join('\n')}

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = {
  'en': () => new Future.value(null),
  'ja': () => new Future.value(null),
};

MessageLookupByLibrary _findExact(localeName) {
  switch (localeName) {
${locales.map((locale) => """
    case '$locale':
      return messages_$locale.messages;""").join('\n')}    
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) async {
  var availableLocale = Intl.verifiedLocale(
    localeName,
    (locale) => _deferredLibraries[locale] != null,
    onFailure: (_) => null);
  if (availableLocale == null) {
    return new Future.value(false);
  }
  var lib = _deferredLibraries[availableLocale];
  await (lib == null ? new Future.value(false) : lib());
  initializeInternalMessageLookup(() => new CompositeMessageLookup());
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  return new Future.value(true);
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary _findGeneratedMessagesFor(locale) {
  var actualLocale = Intl.verifiedLocale(locale, _messagesExistFor,
      onFailure: (_) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
""";


String serviceFile(String allDartPath, List<String> methods) => """
// DO NOT EDIT. This is code generated via intlYaml
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import '$allDartPath';

class I18n {
  I18n(Locale locale) : _localeName = locale.toString();

  final String _localeName;

  static Future<I18n> load(Locale locale) {
    return initializeMessages(locale.toString())
        .then((Object _) {
      return new I18n(locale);
    });
  }

  static I18n of(BuildContext context) {
    return Localizations.of<I18n>(context, I18n);
  }
  
  ${methods.join('\n')}
}
""";