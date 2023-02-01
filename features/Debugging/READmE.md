# Debugging
[`--terragrunt-log-level`](https://terragrunt.gruntwork.io/docs/reference/cli-options/#terragrunt-log-level)オプションを使用してterragruntのログレベルを設定できます。  
合わせて[`--terragrunt-debug`](https://terragrunt.gruntwork.io/docs/reference/cli-options/#terragrunt-debug)フラグを使用します。  

この様なコマンドになります。実行されると`terragrunt-debug.tfvars.json`が生成されます。
```
terragrunt apply --terragrunt-log-level debug --terragrunt-debug
```

# Use-case: I use locals or dependencies in terragrunt.hcl, and the terraform output isn’t what I expected
この様なファイル階層があるとします。
```
└── live
      └── prod
          └── app
          |   ├── vars.tf
          |   ├── main.tf
          |   ├── outputs.tf
          |   └── terragrunt.hcl
          └── ecs-cluster
              └── outputs.tf
```

各ファイルが以下のように構成されているとします。
```
# app/vars.tf
variable "image_id" {
  type = string
}

variable "num_tasks" {
  type = number
}

# app/outputs.tf
output "task_ids" {
  value = module.app_infra_module.task_ids
}

# app/terragrunt.hcl
locals {
  image_id = "acme/myapp:1"
}

dependency "cluster" {
  config_path = "../ecs-cluster"
}

inputs = {
  image_id = locals.image_id
  num_tasks = dependency.cluster.outputs.cluster_min_size
}
```

`terragrunt apply`を実行すると、`outputs.task_ids`は7つの要素を持っていますが、VMは4つしかないことがわかります。調査のため以下のコマンドを実行します。
```
terragrunt apply --terragrunt-log-level debug --terragrunt-debug
```

すると以下の様な標準エラー出力となります。
```
[terragrunt] Variables passed to terraform are located in "~/live/prod/app/terragrunt-debug.tfvars"
[terragrunt] Run this command to replicate how terraform was invoked:
[terragrunt]     terraform apply -var-file="~/live/prod/app/terragrunt-debug.tfvars.json" "~/live/prod/app"
```

`terragrunt-debug.tfvars.json`を見るとこの様になっています。
```
{
    "image_id": "acme/myapp:1",
    "num_tasks": 7
}
```

これを手掛かりに`num_tasks`は4を期待していますが7となっていたので`ecs-cluster/outputs.tf`を見てみます。
```# ecs-cluster/outputs.tf
output "cluster_min_size" {
  value = module.my_cluster_module.cluster_max_size
}
```
Oops, `max`を`min`に修正します。  
このようにローカル変数と依存関係の原因調査に便利です。