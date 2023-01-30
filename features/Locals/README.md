# Locals
ローカル変数を定義でき、inputsブロックなどで参照できる。
```
locals {
  aws_region = "us-east-1"
}

inputs = {
  aws_region  = local.aws_region
  s3_endpoint = "com.amazonaws.${local.aws_region}.s3"
}
```

また、localsの中でlocalsを参照することも可。
```
locals {
  x = 2
  y = 40
  answer = local.x + local.y
}
```

# Including globally defined locals
以下の様なディレクトリ構成で`common_vars.yaml`を定義し(yaml or json)グローバルに参照できる。
```
.
├── terragrunt.hcl
├── common_vars.yaml
├── mysql
│   └── terragrunt.hcl
└── vpc
    └── terragrunt.hcl
```

子ディレクトリの`terragrunt.hcl`で以下の様に読み込める。
```
# child terragrunt.hcl
locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  region = "us-east-1"
}
```