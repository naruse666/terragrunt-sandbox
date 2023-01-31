# Auto-Init
これはデフォルトで有効で、`terragrunt plan`などを実行した際にterragruntが以下を検知すると`terraform init`が実行される感じ。
- `terraform init`が一度も実行されていない
- `source`をダウンロードする必要がある
- モジュールに`.terragrunt-init-required`が存在する(dir: `.terragrunt-cache/aaa/bbb/modules/<module>`)
- remote stateが前回の`terraform init`実行時から変更されている
  
[`extra_arguments`](https://terragrunt.gruntwork.io/docs/features/keep-your-cli-flags-dry/#extra_arguments-for-init)を使い`terraform init`をカスタマイズできます。

### disable Auto-init
[`terragrunt-no-auto-init`](https://terragrunt.gruntwork.io/docs/reference/cli-options/#terragrunt-no-auto-init)オプション。もしくは、`TERRAGRUNT_AUTO_INIT`にfalseをセットする。