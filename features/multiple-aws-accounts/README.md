# Work with multiple AWS accounts
AWSのスイッチロールの退屈な作業をterragruntで行う。
- [`--terragrunt-iam-role`](https://terragrunt.gruntwork.io/docs/reference/cli-options/#terragrunt-iam-role)を使用する。
```
terragrunt apply --terragrunt-iam-role "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
```

- `TERRAGRUNT_IAM_ROLE`環境変数にIAMロールをセットする。
```
export TERRAGRUNT_IAM_ROLE="arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
terragrunt apply
```

- terragruntのconfigに[`iam_role`](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#iam_role)プロパティを設定する。
```
iam_role = "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
```