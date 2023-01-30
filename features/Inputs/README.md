# Inputs
[`inputs`](https://terragrunt.gruntwork.io/docs/reference/config-blocks-and-attributes/#inputs)ブロックを使用してモジュールに値を与えられる。 
terragruntコマンドが実行されるとinputsの値を環境変数`TF_VAR_xxx`にセットされる。  
`TF_VAR_xxx`環境変数が既に設定されている場合、terragruntはそちらを優先する。
