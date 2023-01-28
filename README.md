# terragrunt-sandbox
[Terragrunt](https://terragrunt.gruntwork.io/)キャッチアップ用のリポジトリ。

# ざっくり概要
- `terragrunt.hcl`に設定を記載する。
- [Terraform Registry Module](https://registry.terraform.io/browse/modules)の参照に`tfr://`プロトコルが使用される。
```
tfr://REGISTRY_DOMAIN/MODULE?version=VERSION
```
- Terragruntが対応しているterraformのバージョン表.[Supported Terraform Versions](https://terragrunt.gruntwork.io/docs/getting-started/supported-terraform-versions/)
- `.terragrunt-cache/`ディレクトリにキャッシュされる。(これはignoreしたほうが...?)
- terraformと同じように`terragrunt [init | plan | apply]`を実行できる。
- 公式に出てくるDRYは、“Don’t Repeat Yourself”という意味。
- `terragrunt hclfmt`.(terraform fmt -recursiveと同じ)`--terragrunt-check`オプションをつけれる。
- `terragrunt graph-dependencies`コマンドで依存関係を表せる。(`terraform graph`の様な)
