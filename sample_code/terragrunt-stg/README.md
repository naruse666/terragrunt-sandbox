# Backend Configuration 
以下のような構成で`terragrunt.hcl`で`remote_state`ブロック定義すれば、s3バックエンド等の指定のterraformファイルを生成してくれる。  
`path_relative_to_include`関数で子フォルダの`terragrunt.hcl`を見つけてくれる。
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
# Provider Configuration
`generate`ブロックで`provider`を定義している。  
`contents`には`file()`を使用することもできる。

# CLI Arguments
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
