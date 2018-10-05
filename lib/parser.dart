/*
 * Copyright (c) 2018. tanakeiQ. All rights reserved.
 * License - MIT
 *
 * Author
 * - tanakeiQ<https://twitter.com/tanakeiQ>
 */

library intl_yaml;

import 'dart:core';

import 'stub.dart' as Stub;
import 'stub_file.dart' as StubFile;

class Parser {

  /* Source Code */

  static String getMessage(String key, dynamic values) {
    if (values is String) {
      return Stub.simple(key, values);
    } else if (values is Map) {
      String value = values['value'];
      List<String> params = _parseParam(value);

      var namedParams = [];
      params.forEach((param) {
        // Remove `:`
        var _param = Stub.namedParam(param.substring(1));
        value = value.replaceAll(param, _param);

        namedParams.add(param.substring(1));
      });

      return Stub.named(key, namedParams.join(', '), value);
    }

    return null;
  }

  static String getMethod(String key, dynamic values) {
    if (values is String) {
      return Stub.method(key, Stub.empty, values, key);
    } else if (values is Map) {
      String value = values['value'];
      List<String> params = _parseParam(value);

      var namedParams = [];
      params.forEach((param) {
        // Remove `:`
        var _param = Stub.namedParam(param.substring(1));
        value = value.replaceAll(param, _param);

        namedParams.add(param.substring(1));
      });

      //Set option

      List<String>opt = [];

      // args: ['']
      opt.add(Stub.methodParam(namedParams.join(Stub.commaSpace)));

      // examples: const {};
      if (values.containsKey('examples')) {
        if (values['examples'] is! Map) {
          throw Exception('examples must be `Map`');
        }

        Map examples = values['examples'];
        List<String> exampleValues = [];

        examples.forEach((key, value) {
          exampleValues.add(Stub.methodExampleValue(key, value));
        });
        opt.add(Stub.methodExamples(exampleValues.join(Stub.commaBreak)));
      }

      return Stub.method(key, namedParams.join(Stub.commaSpace), value, key, opt: opt.join(Stub.commaBreak));
    }

    return null;
  }

  static List<String> _parseParam(String value) {
    Iterable<Match> params = new RegExp(r'(:.+?(?= |$))').allMatches(value);

    return params.map((v) => v.group(0)).toList();
  }

  /* File */

  static String getAllFile(String filePrefix, List<String> locales) => StubFile.allFile(filePrefix, locales);

  static String getLocaleFile(String locale, List<String> methods) => StubFile.localeFile(locale, methods);

  static String getServiceFile(String allDartPath, List<String> methods) => StubFile.serviceFile(allDartPath, methods);
}