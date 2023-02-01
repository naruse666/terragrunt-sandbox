# Lock File Handling
## The long version: details of how Terragrunt handles lock files
### What’s a lock file?
`terraform init`実行時に`.terraform.lock.hcl`が作成されます。  
これはあなたが使用しているproviderのキャプチャが記されています。

### The problem with mixing remote Terraform configurations in Terragrunt and lock files
以下の構成だとします。
```
└── live
    ├── prod
    │   └── vpc
    │       └── terragrunt.hcl
    └── stage
        └── vpc
            └── terragrunt.hcl
```                        
そして`/live/stage/vpc/terragrunt.hcl`が以下の様になっています。
```
terraform {
  source = "git::git@github.com:acme/infrastructure-modules.git//networking/vpc?ref=v0.0.1"
}
```

`terragrunt apply`が実行されると`.terragrunt-cache/xxx/vpc`が生成され、`.terraform.lock.hcl`は`/live/stage/vpc`フォルダではなく`.terragrunt-cache/xxx/vpc`に生成されます。

### How Terragrunt solves this problem
`v0.27.0`以降でterragruntは以下の様な機能を備えています。  
- terraform実行前にワーキングディレクトリ(`/live/stage/vpc`)から`.terraform.lock.hcl`を探し、tmpディレクトリ(`.terragrunt-cache/xxx/vpc`)にそれをコピーします。
- terraform実行後、tmpディレクトリで`.terraform.lock.hcl`を見つけた場合にワーキングディレクトリに戻します。

### Check the lock file in!
各モジュールでterragruntを実行後、ロックファイルをVCSへチェックインする必要があります。以下の様になります。
```
└── live
    ├── prod
    │   └── vpc
    │       ├── .terraform.lock.hcl
    │       └── terragrunt.hcl
    └── stage
        └── vpc
            ├── .terraform.lock.hcl
            └── terragrunt.hcl
```            