# intl_yaml

This package able to Auto implement [intl](https://pub.dartlang.org/packages/intl) globalization method from yaml.

## Getting Started

### install

```yaml
  intl_yaml: ^0.0.1
```

### usage

1. install `intl`

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
```

2. create globalize yaml

e.g.

**assets/i18n/en.yaml**

```yaml
make: 'Make'
stock: 'Stock'
helloUser:
  value: 'hello :user'
  examples:
    user: 'Guest'
```


**assets/i18n/ja.yaml**

```yaml
make: '作る'
stock: 'ストック'
helloUser:
  value: ':user　さん、こんにちわ'
  examples:
    user: 'ゲスト'
```


3. execute

```bash
  --config-file 'select globalize file'
  --config-dir 'select globalize dir(ignore if use `--config-file`)'
  --out-lang-dir 'select dir to output the globalize method';
  --out-service-dir 'select dir to output the globalize service';
  --file-prefix 'globalize method file prefix (defailt: intl_message)';
  --default-locale 'default locale(default: en)';
  --project-name(-p) 'project name(temporary option)';
```

