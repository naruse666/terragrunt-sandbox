## Immutable versioned Terraform modules
既に作成した別のリポジトリのモジュールを再利用できる。これぞDRYって感じ！  
`terraform`ブロックで`source`を指定し、対象モジュールの`input`も指定する。  
ここで`terragrunt apply`をするとルートで`remote_state, provider`が指定されているが、作業ディレクトリには`provider.tf`等は作成されない。(通常のモジュールの利用を考えると当然)  
公式に記載がないが、`.terragrunt-cache`フォルダを見ると`provider.tf`が作成されていた。  
サンプルで用意した[terraform-module-reference-from-terragrunt](https://github.com/naruse666/terraform-module-reference-from-terragrunt)リポジトリを使用する。  
urlは`//`をつける必要がある。
```
terraform {
  source = "git@github.com:naruse666/terraform-module-reference-from-terragrunt.git//modules/ec2?ref=v0.0.1"
}
inputs = {
  instance_type  = "t2.micro"
}
```
