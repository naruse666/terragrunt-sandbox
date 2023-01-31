# Before and After Hooks
`terragrunt`コマンドの実行前、実行後にアクションを定義できる。
```
terraform {
  before_hook "before_hook" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "Running Terraform"]
  }

  after_hook "after_hook" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "Finished running Terraform"]
    run_on_error = true
  }
}
```

また、befor, afterともに重ねて定義することも可能。
```
terraform {
  before_hook "before_hook_1" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "Will run Terraform"]
  }

  before_hook "before_hook_2" {
    commands     = ["apply", "plan"]
    execute      = ["echo", "Running Terraform"]
  }
}
```

## Tflint Hook
`tflint`をサポートしているので以下の様な使い方ができる。  
`terragrunt.hcl`かその親と同じディレクトリに存在する必要がある。
```
terraform {
  before_hook "before_hook" {
    commands     = ["apply", "plan"]
    execute      = ["tflint"]
  }
}
```

### Authentication for tflint rulesets
Private rulesetsを利用する場合、`GITHUB_TOKEN`をexportする必要がある。

### Troubleshooting
参考リンクのみ貼ります。
[Troubleshooting](https://terragrunt.gruntwork.io/docs/features/hooks/#troubleshooting)

# Error Hooks
before/after hooksの後に実行される。
```
terraform {
  error_hook "import_resource" {
    commands  = ["apply"]
    execute   = ["echo", "Error Hook executed"]
    on_errors = [
      ".*",
    ]
  }
}
```