/*
 * Copyright (c) 2018. tanakeiQ. All rights reserved.
 * License - MIT
 *
 * Author
 * - tanakeiQ<https://twitter.com/tanakeiQ>
 */

library intl_yaml;

String comma = ",";
String commaBreak = ",\n";
String commaSpace= ", ";
String empty = '';

String simple(key, value) => "'$key' : MessageLookupByLibrary.simpleMessage('$value')";
String named(key, param, value) => "'$key': ($param) => '$value'";
String namedParam(param) => "\${$param}";

String method(method, param, value, name, {String opt}) => """
  String ${param != "" ? '$method($param)' : 'get $method'} => Intl.message(
      '$value',
      locale: _localeName,
      name: '$name'${opt == null ? empty : comma}
      ${opt == null ? empty : opt}
      );
""";

String methodParam(param) => "args: [$param]";
String methodExamples(value) => "examples: const {$value}";
String methodExampleValue(key, value) => "'$key': '$value'";