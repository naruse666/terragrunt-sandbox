# Auto-Retry
auto retryはterragruntの機能で`terraform`コマンドを再実行が必要な場合にre-runされます。  
`terragrunt.hcl`に以下の様にしてカスタムをoverrideできます。
```
retryable_errors = [
  "a regex to match the error",
  "another regex"
]
```

### Default
Auto retryはデフォルトで最大3回(それぞれ5s待機する)再試行されます。  
これはオーバーライドできます。
```
retry_max_attempts = 5
retry_sleep_interval_sec = 60
```

### Disable
- [`--terragrunt-no-auto-retry`](https://terragrunt.gruntwork.io/docs/reference/cli-options/#terragrunt-no-auto-retry)を引数に設定
- `TERRAGRUNT_AUTO_RETRY`環境変数を`false`に設定