# Terragrunt Architecture
以下の様な環境が分離された階層があるとして、`_env/app.hcl`と`qa/app/terragrunt.hcl`を例に挙げて説明する。  
モジュールのinputを共有できる。
```
features/terragrunt-architecture/
├── README.md
├── _env
│   ├── app.hcl
│   ├── mysql.hcl
│   └── vpc.hcl
├── stg
│   ├── app
│   │   └── terragrunt.hcl
│   ├── mysql
│   │   └── terragrunt.hcl
│   └── vpc
│       └── terragrunt.hcl
├── prod
│   ├── app
│   │   └── terragrunt.hcl
│   ├── mysql
│   │   └── terragrunt.hcl
│   └── vpc
│       └── terragrunt.hcl
├── qa
│   ├── app
│   │   └── terragrunt.hcl
│   ├── mysql
│   │   └── terragrunt.hcl
│   └── vpc
│       └── terragrunt.hcl
└── terragrunt.hcl
```

## _envフォルダ
公式には書いていないが、`dependency.<module>.outputs.<attr>`でモジュールのアウトプットを参照できる。
```_env/app.hcl
terraform {
  source = "github.com/<org>/modules.git//app?ref=v0.1.0"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "mysql" {
  config_path = "../mysql"
}

inputs = {
  basename       = "example-app"
  vpc_id         = dependency.vpc.outputs.vpc_id
  subnet_ids     = dependency.vpc.outputs.subnet_ids
  mysql_endpoint = dependency.mysql.outputs.endpoint
}
```

## qaフォルダ
`include "env"`を使用して相対パスで`_env/app.hcl`を参照。
```qa/app/terragrunt.hcl
include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path = "${get_terragrunt_dir()}/../../_env/app.hcl"
}

inputs = {
  env = "qa"
}
```

# 子階層でのオーバーライド
`_env/app.hcl`でモジュールのバージョン`v0.1.0`を利用していた。qa環境では`v0.2.0`を使いたい時は以下の様に`terraform`ブロックでオーバーライドできる。  
prod/app, stg/appは`v0.1.0`だがqa/appは`v0.2.0`を実現できる。
```qa/app/terragrunt.hcl
include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path = "${get_terragrunt_dir()}/../../_env/app.hcl"
}

# Override the terraform.source attribute to v0.2.0
terraform {
  source = "github.com/<org>/modules.git//app?ref=v0.2.0"
}

inputs = {
  env = "qa"
}
```

# URLのDRY
`qa/app/terragrunt.hcl`でurlを直接指定しないようにする。  
_envで`locals`ブロックを定義する。
```_env/app.hcl
# 追記
locals {
  source_base_url = "github.com/<org>/modules.git//app"
}
```

オーバーライドしていた`terraform`ブロックを以下の様に書き換える。  
`include`を通して`_env/app.hcl`の変数を読みにいけている。  
この時`include`ブロックで`expose = true`を設定する。
```qa/app/terragrunt.hcl
include "env" {
  path = "${get_terragrunt_dir()}/../../_env/app.hcl"
  expose = true
}

terraform {
  source = "${include.env.locals.source_base_url}?ref=v0.2.0"
}
```

# read_terragrunt_config
`qa/app/terragrunt.hcl`で以下の様にenvを定義していたが、これを各環境で繰り返さないために、親のファイルから参照させることができる。
```qa/app/terragrunt.hcl
inputs = {
  env = "qa"
}
```

各環境(prod, stg, qa)下で`env.hcl`を作成する。  
以下の様に`locals`変数を定義する。これを親の`_env/app.hcl`から読み込むことでprod, stg, qaのenv変数を動的に設定できる。
```qa/env.hcl
locals {
  env = "qa" 
}
```

`_env/app.hcl`で以下の様にして親hclから子を参照する。
```_env/app.hcl
locals {
  # env.hclという名前を探している
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env_name = local.env_vars.locals.env

  source_base_url = "https://....com"
}

~~~~

inputs {
  env = local.env_name
  basename = "example-app-${local.env_name}"
  ~~~~
}
```

そして`qa/app/terragrunt.hcl`からinputsを削除する。

# CI/CDへの考慮
## `include`と`read_terragrunt_config`を使用していない場合
更新された`terragrunt.hcl`ファイルを`--terragrunt-config`を使用して`terragrunt plan`, `terragrunt apply`を実行できる。

## `include`と`read_terragrunt_config`を使用している場合
例えば`_env/app.hcl`を変更した場合、全てのモジュールを変更する必要がある。
が、`read_terragrunt_config`は現在サポートされていない。`include`は[run-all](https://terragrunt.gruntwork.io/docs/reference/cli-options/#run-all)コマンドに、[--terragrunt-modules-that-include](https://terragrunt.gruntwork.io/docs/reference/cli-options/#terragrunt-modules-that-include)オプションを使用できる。  
`terragrunt run-all plan --terragrunt-modules-that-include _env/app.hcl`のようなコマンドとなる。

## 段階的なロールアウト
`_env/app.hcl`に依存関係が複数ある(prod,stg...)場合、`--terragrunt-working-dir`を使用して以下の様に実行できる。
```
# Roll out the change to the qa environment first
terragrunt run-all plan --terragrunt-modules-that-include _env/app.hcl --terragrunt-working-dir qa
terragrunt run-all apply --terragrunt-modules-that-include _env/app.hcl --terragrunt-working-dir qa
# If the apply succeeds to qa, move on to the stage environment
terragrunt run-all plan --terragrunt-modules-that-include _env/app.hcl --terragrunt-working-dir stage
terragrunt run-all apply --terragrunt-modules-that-include _env/app.hcl --terragrunt-working-dir stage
# And finally, prod.
terragrunt run-all plan --terragrunt-modules-that-include _env/app.hcl --terragrunt-working-dir prod
terragrunt run-all apply --terragrunt-modules-that-include _env/app.hcl --terragrunt-working-dir prod
```

