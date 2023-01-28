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

# サンプル
## Backend Configuration
`場所: sample_code/terragrunt-stg`  
以下のような構成で`terragrunt.hcl`で`remote_state`ブロック定義すれば、s3バックエンド等の指定のterraformファイルを生成してくれる。
```
stg
├── terragrunt.hcl
├── frontend-app
│   ├── main.tf
│   └── terragrunt.hcl
└── mysql
    ├── main.tf
    └── terragrunt.hcl
```
## Provider Configuration
`場所: sample_code/terragrunt-stg`  
terraformの`provider`ブロックをルートに定義すると`provider.tf`を自動生成してくれる。

## CLI Arguments
`場所: sample_code/terragrunt-stg`  
子フォルダの`terragrunt.hcl`に以下のような`terraform`ブロックを定義すると、指定のコマンドに引数を自動でつけてくれる。  
commandsに`get_terraform_commands_that_need_vars()`を指定すると全てのterraformコマンドに引数を加えてくれる。
```
terraform {
  extra_arguments "common_vars" {
    commands = ["plan", "apply"]

    arguments = [
      "-var-file=../../common.tfvars",
      "-var-file=../region.tfvars"
    ]
  }
}
```

## Immutable versioned Terraform modules
`場所: sample_code/across`  
既に作成した別のリポジトリのモジュールを再利用できる。これぞDRYって感じ！  
`terraform`ブロックで`source`を指定し、対象モジュールの`input`も指定する。  
ここで`terragrunt apply`をするとルートで`remote_state, provider`が指定されているが、作業ディレクトリには`provider.tf`等は作成されない。(通常のモジュールの利用を考えると当然)  
公式に記載がないが、`.terragrunt-cache`フォルダを見ると`provider.tf`が作成されていた。  
urlは`//`をつける必要がある。
```
terraform {
  source = "git@github.com:naruse666/terraform-module-reference-from-terragrunt.git//modules/ec2?ref=v0.0.1"
}
inputs = {
  instance_type  = "t2.micro"
}
```
