# Execute Terraform commands on multiple modules at once
以下の様なフォルダ構成があったとする。リソースを構築するには各サブフォルダで`terraform apply`を実行する必要があるが、これってつまんないよねって話。
```
root
├── backend-app
│   └── main.tf
├── frontend-app
│   └── main.tf
├── mysql
│   └── main.tf
├── redis
│   └── main.tf
└── vpc
    └── main.tf
```

## run-all Command
各サブフォルダに`terragrunt.hcl`を配置する。(これをすることでterragruntの管理下にあると認識されるイメージ。名前は`terragrunt.hcl`でなければいけない。)  
そして、rootフォルダで`terragrunt run-all apply`を実行する。[run-all](https://terragrunt.gruntwork.io/docs/reference/cli-options/#run-all)から`plan, output, destroy`等も実行できることがわかる。
```
root
├── backend-app
│   ├── main.tf
│   └── terragrunt.hcl
├── frontend-app
│   ├── main.tf
│   └── terragrunt.hcl
├── mysql
│   ├── main.tf
│   └── terragrunt.hcl
├── redis
│   ├── main.tf
│   └── terragrunt.hcl
└── vpc
    ├── main.tf
    └── terragrunt.hcl
```

### Note
- モジュールAがモジュールBに依存していて、モジュールBが適用されていない場合、`run-all plan`を実行するとBのプランを表示するがエラーを出す。
- `terragrunt run-all destroy`コマンドを実行するとカレントディレクトリ配下のモジュールを全て削除する。  
依存関係を破壊しないために[`--terragrunt-ignore-external-dependencies`](https://terragrunt.gruntwork.io/docs/reference/cli-options/#terragrunt-ignore-external-dependencies), [`--terragrunt-exclude-dir`](https://terragrunt.gruntwork.io/docs/reference/cli-options/#terragrunt-exclude-dir)を使用できる。

# Passing outputs between modules
以下の様な構成でmysqlのinputにサブネットIDを渡したい時、mysqlがvpcモジュールに依存していることとなる。
```
root
├── backend-app
│   ├── main.tf
│   └── terragrunt.hcl
├── mysql
│   ├── main.tf
│   └── terragrunt.hcl
├── redis
│   ├── main.tf
│   └── terragrunt.hcl
└── vpc
    ├── main.tf
    └── terragrunt.hcl
```

## dependency
以下の様に[dependency](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#dependency)ブロックを使用して、別モジュールのoutputを参照できる。  
ここでoutputを参照できるのはvpcモジュールにterraformの[output](https://developer.hashicorp.com/terraform/language/values/outputs)ブロックが`vpc_id`という名前で定義されているため。
```mysql/terragrunt.hcl
dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
}
```

### applyの順番
以下の様にバックエンドアプリにmysqlとredisに依存関係があることを定義します。  
mysqlはvpcに、backend-appはmysql, redisに依存関係があることをterragruntが認識します。
```backend-app/terragrunt.hcl
dependency "mysql" {
  config_path = "../mysql"
}

dependency "redis" {
  config_path = "../redis"
}

inputs = {
  mysql_url = dependency.mysql.outputs.domain
  redis_url = dependency.redis.outputs.domain
}
```

`run-all apply`を実行すると、このような順でapplyされます。
```
vpc -> mysql, redis -> backend-app
```

# Unapplied dependency and mock outputs
依存関係のあるモジュールのoutputを参照する定義を書いた際、そのモジュールがapplyされていない場合はterragruntはエラーを返します。(`run-all plan`と`run-all validate`実行時。) 

## mock_outputs
これを回避するのに`mock_outputs`を使用します。  
また、`mock_outputs_allowed_terraform_commands`を使用することにより対象のコマンドのみに制限できる。
```mysql/terragrunt.hcl
dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "temporary-dummy-id"
  }
  mock_outputs_allowed_terraform_commands = ["validate"]
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
}
```

## skip_outputs
これはbackend initializationを無効(`remote_state.disable_init`)にしている時に便利で、remote_stateからpullせずに実行される。(`mock_outputs`を指定する必要あり)
```
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "temporary-dummy-id"
  }

  skip_outputs = true
}
```

## mock_outputs_merge_strategy_with_state
モジュールのoutputに`vpc_id`のみがあり、`new_output`が含まれない場合`new_output`にはモックの値が使用されます。
```
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id     = "temporary-dummy-id"
    new_output = "temporary-dummy-value"
  }

  mock_outputs_merge_strategy_with_state = "shallow"
}
```

# Dependencies between modules
以下の様な依存関係を定義する場合。
- backend-app depends on mysql, redis, and vpc
- frontend-app depends on backend-app and vpc
- mysql depends on vpc
- redis depends on vpc
- vpc has no dependencies

[dependencies](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#dependencies)ブロックを使用し、以下の様に定義できる。
```backend-app/terragrunt.hcl
dependencies {
  paths = ["../vpc", "../mysql", "../redis"]
}
```

# Dependencies Graph
[graph-dependencies](https://terragrunt.gruntwork.io/docs/reference/cli-options/#graph-dependencies)コマンドを使用すると依存関係を出力できる。  
例えば以下の様にしてpngに落とせる。
`terragrunt graph-dependencies |dot -Tpng > graph.png`

# Testing multiple modules locally
`source`に指定したGit URLをローカルにcheckoutして使用する場合、[--terragrunt-source](https://terragrunt.gruntwork.io/docs/reference/cli-options/#terragrunt-source)オプションを使用することでローカルを参照できる。
```
terragrunt run-all plan --terragrunt-source /source/modules
```
この時以下のように`source`が定義されていた場合、`/source/infrastructure-modules//networking/vpc`を参照する。
```
terraform {
  source = "git::git@github.com:acme/infrastructure-modules.git//networking/vpc?ref=v0.0.1"
}
```

# Limiting the module execution parallelism
依存関係をトラバースする際に大量のモジュールが存在するとクラウドプロバイダのレート制限にかかる可能性がある。  
[terragrunt-parallelism](https://terragrunt.gruntwork.io/docs/reference/cli-options/#terragrunt-parallelism)を使用して平行実行数を指定できる。
```
terragrunt run-all apply --terragrunt-parallelism 4
```