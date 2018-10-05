/*
 * Copyright (c) 2018. tanakeiQ. All rights reserved.
 * License - MIT
 *
 * Author
 * - tanakeiQ<https://twitter.com/tanakeiQ>
 */

library intl_yaml;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:intl_yaml/parser.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

class Cmd {
  static String configFile = 'config-file';
  static String configDir = 'config-dir';
  static String outLangDir = 'out-lang-dir';
  static String outServiceDir = 'out-service-dir';
  static String filePrefix = 'file-prefix';
  static String defaultLocale = 'default-locale';
  //TODO: temporary solution.
  static String projectName = 'project-name';
}

String configFile;
String configDir;
String outLangDir;
String outServiceDir;
String filePrefix;
String defaultLocale;
//TODO: temporary solution.
String projectName;

List<String> supportLocales = [];

final yamlExt = 'yaml';
final dartExt = 'dart';

final serviceFilename = 'I18n';

main(List<String> argument) async {
  final parser = new ArgParser()
    ..addOption(Cmd.configFile)
    ..addOption(Cmd.configDir)
    ..addOption(Cmd.filePrefix, defaultsTo: 'intl_message')
    ..addOption(Cmd.outLangDir)
    ..addOption(Cmd.outServiceDir)
    ..addOption(Cmd.defaultLocale, defaultsTo: 'en')
    ..addOption(Cmd.projectName, abbr: 'p');

  ArgResults args = parser.parse(argument);

  _initPram(args);

  if (isEmpty(args[Cmd.configFile]) && isEmpty(args[Cmd.configDir])) {
    stderr.writeln('Not select config file path(use `--config-file`) or file dir(use `--config-dir`)'); return;
  }

  if (isEmpty(args[Cmd.projectName])) {
    stderr.writeln('Not select project name(user `--project-name` or `-p`).'); return;
  }

  _initSupportLocale();

  if (!supportLocales.contains(defaultLocale)) {
    stderr.writeln('Not define default `$defaultLocale` locale file.'); return;
  }

  String allDartPath = _writeAllMessage();

  supportLocales.forEach((locale) {
    _loadConfigFile('$configDir/$locale.$yamlExt').then((Map config) {
      List<String> messages = [];
      List<String> methods = [];

      config.forEach((key, value) {
        messages.add(Parser.getMessage(key ,value));

        if (defaultLocale == locale) {
          methods.add(Parser.getMethod(key ,value));
        }
      });

      print(messages);
      _writeMessage(locale, messages);

      if (defaultLocale == locale) {
        _writeMethod(allDartPath, methods);
      }

    }).catchError((e) {
      stderr.writeln(e);
      stderr.writeln('Failed to load config file. `${args[Cmd.configFile]}`');
      return;
    });
  });
}


Future<Map> _loadConfigFile(String path) async {
  var completer = new Completer<Map>();

  var file = new File(path);
  bool exists = await file.exists();

  if (exists) {
    String yamlString = await file.readAsString();
    Map yaml = loadYaml(yamlString);
    completer.complete(yaml);
  } else {
    completer.completeError("${path} does not exist");
  }

  return completer.future;
}

void _initPram(args) {
  configFile = args[Cmd.configFile];
  configDir = args[Cmd.configDir];
  outLangDir = args[Cmd.outLangDir];
  outServiceDir = args[Cmd.outServiceDir];
  filePrefix = args[Cmd.filePrefix];
  defaultLocale = args[Cmd.defaultLocale];
  projectName = args[Cmd.projectName];
}

void _initSupportLocale() {
  RegExp localeRegExp = new RegExp(r'[^\/]*$');
  if (!isEmpty(configFile)) {
    var file = new File(configFile);
    configDir = dirname(file.path);
    supportLocales = [basename(file.path).split('.').first];
  } else {
    var dir = new Directory(configDir);
    dir.listSync().forEach((content) {
      if (content is File) {
        String filename = localeRegExp.stringMatch(content.path);
        supportLocales.add(filename.split('.').first);
      }
    });
  }
}

String _writeMessage(String locale, List<String> messages) {
  var localeFile = Parser.getLocaleFile(locale, messages);
  var file = new File('$outLangDir/${filePrefix}_$locale.$dartExt');
  file.writeAsStringSync(localeFile);

  return file.path;
}

String _writeAllMessage() {
  var allFile = Parser.getAllFile(filePrefix, supportLocales);
  var file = new File('$outLangDir/${filePrefix}_all.$dartExt');
  file.writeAsStringSync(allFile);

  return file.path;
}

String _writeMethod(String allDartPath, List<String> methods) {
  allDartPath = allDartPath.replaceAll('lib', projectName);
  var serviceFile = Parser.getServiceFile('package:$allDartPath', methods);
  var file = new File('$outServiceDir/$serviceFilename.$dartExt');
  file.writeAsStringSync(serviceFile);

  return file.path;
}


bool isNull(String s) => s == null;
bool isEmpty(String s) => s == null || s == '';